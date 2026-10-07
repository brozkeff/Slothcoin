"""Test a disposable offline wallet without accessing the user's wallet."""
from __future__ import annotations

import base64
import json
import secrets
import socket
import subprocess
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path


def main() -> None:
    binary = Path(__file__).resolve().parents[1] / "src" / "Slothcoind"
    with tempfile.TemporaryDirectory(prefix="slothcoin-build5-") as temporary:
        directory = Path(temporary)
        with socket.socket() as listener:
            listener.bind(("127.0.0.1", 0))
            port = listener.getsockname()[1]
        password = secrets.token_hex(32)
        config = directory / "Slothcoin.conf"
        config.write_text(f"rpcuser=build5-test\nrpcpassword={password}\nrpcport={port}\n")
        config.chmod(0o600)
        credentials = base64.b64encode(f"build5-test:{password}".encode()).decode()

        def rpc(method: str, params: list[object] | None = None) -> object:
            payload = json.dumps({"method": method, "params": params or [], "id": 1}).encode()
            request = urllib.request.Request(
                f"http://127.0.0.1:{port}/", data=payload,
                headers={"Authorization": f"Basic {credentials}"},
            )
            with urllib.request.urlopen(request, timeout=5) as response:
                result = json.load(response)
            if result["error"]:
                raise RuntimeError(result["error"])
            return result["result"]

        command = [str(binary), f"-datadir={directory}", "-listen=0", "-dnsseed=0",
                   "-connect=0", "-upnp=0", "-server", "-keypool=2"]

        def wait_for_rpc(daemon: subprocess.Popen[bytes]) -> object:
            for _ in range(120):
                if daemon.poll() is not None:
                    raise RuntimeError(f"Daemon exited: {daemon.communicate()[1].decode()}")
                try:
                    return rpc("getinfo")
                except (OSError, urllib.error.URLError):
                    time.sleep(0.25)
            raise RuntimeError("RPC did not start within 30 seconds")

        process = subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        try:
            info = wait_for_rpc(process)
            assert isinstance(info, dict) and info["version"] == 1030105, info
            address = rpc("getnewaddress")
            assert isinstance(address, str)
            exported = rpc("dumpprivkey", [address])
            rpc("stop")
            assert process.wait(timeout=30) == 0
            # Import into a different wallet so an existing key cannot mask failure.
            imported_directory = directory / "import-wallet"
            imported_directory.mkdir()
            imported_config = imported_directory / "Slothcoin.conf"
            imported_config.write_text(config.read_text())
            imported_config.chmod(0o600)
            command[1] = f"-datadir={imported_directory}"
            process = subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
            wait_for_rpc(process)
            rpc("importprivkey", [exported, "build5-roundtrip", False])
            validated = rpc("validateaddress", [address])
            assert isinstance(validated, dict) and validated["ismine"], validated
            invalid_headers = [
                "Content-Length: 99999999999999999999999999",
                "Content-Length: -1",
                "Content-Length: 1x",
                "Content-Length: 1\r\nContent-Length: 1",
                "Transfer-Encoding: chunked",
            ]
            for headers in invalid_headers:
                with socket.create_connection(("127.0.0.1", port), timeout=5) as connection:
                    connection.sendall(f"POST / HTTP/1.1\r\n{headers}\r\n\r\n".encode())
                    with connection.makefile("rb") as response_stream:
                        response = response_stream.readline(8192)
                    assert b"500" in response or b"400" in response, response
                rpc("getinfo")
            rpc("stop")
            assert process.wait(timeout=30) == 0
            process = subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
            wait_for_rpc(process)
            assert rpc("dumpprivkey", [address]) == exported
            rpc("stop")
            assert process.wait(timeout=30) == 0
            print("Offline startup, RPC, key import/export and wallet persistence passed")
        finally:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()


if __name__ == "__main__":
    main()
