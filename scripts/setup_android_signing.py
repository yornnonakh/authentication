#!/usr/bin/env python3
"""Create a new local upload key. Existing Play apps may require their original key."""

import os
from pathlib import Path
import secrets
import shutil
import subprocess
import tempfile


def main():
    android = Path(__file__).resolve().parents[1] / "android"
    properties = android / "key.properties"
    keystore = android / "upload-keystore.jks"
    certificate = android / "upload-certificate.pem"
    if properties.exists():
        print("android/key.properties already exists; no signing files were changed.")
        return
    if keystore.exists() or certificate.exists():
        raise SystemExit("Signing files already exist. Configure key.properties for that key.")
    keytool = shutil.which("keytool")
    if keytool is None:
        raise SystemExit("Install a JDK and make keytool available on PATH.")

    password = secrets.token_urlsafe(36)
    environment = dict(os.environ, FINSIGHT_UPLOAD_PASSWORD=password)
    created = []
    try:
        with tempfile.TemporaryDirectory(prefix="finsight-signing-") as temporary:
            temporary_key = Path(temporary) / "upload.jks"
            command = [
                keytool, "-genkeypair", "-noprompt", "-keystore", str(temporary_key),
                "-storetype", "JKS", "-keyalg", "RSA", "-keysize", "2048",
                "-validity", "10000", "-alias", "upload",
                "-dname", "CN=Finsight Upload",
                "-storepass:env", "FINSIGHT_UPLOAD_PASSWORD",
                "-keypass:env", "FINSIGHT_UPLOAD_PASSWORD",
            ]
            subprocess.run(command, env=environment, check=True, capture_output=True)
            exported = subprocess.run(
                [keytool, "-exportcert", "-rfc", "-keystore", str(temporary_key),
                 "-alias", "upload", "-storepass:env", "FINSIGHT_UPLOAD_PASSWORD"],
                env=environment, check=True, capture_output=True,
            ).stdout
            settings = (
                "storeFile=upload-keystore.jks\n"
                f"storePassword={password}\n"
                "keyAlias=upload\n"
                f"keyPassword={password}\n"
            ).encode()
            for destination, data in (
                (keystore, temporary_key.read_bytes()),
                (certificate, exported),
                (properties, settings),
            ):
                descriptor = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
                created.append(destination)
                with os.fdopen(descriptor, "wb") as output:
                    output.write(data)
    except BaseException:
        for destination in reversed(created):
            destination.unlink(missing_ok=True)
        raise

    print("Created android/upload-keystore.jks and android/key.properties.")
    print("Public upload certificate: android/upload-certificate.pem")
    print("Back up the keystore and key.properties securely; passwords were not printed.")
    print("An existing Play upload certificate must match, or be reset in Play Console.")


if __name__ == "__main__":
    main()
