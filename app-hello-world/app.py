from flask import Flask
import os

app = Flask(__name__)

target = os.environ.get("HELLO_TARGET", "world")


@app.route("/healthz")
def get_healthz():
    return "OK"


@app.route(f"/{target}")
def get_hello():
    return f"Hello, {target}!"


if __name__ == "__main__":
    app.run(host="0.0.0.0")  # Note - if host not specified, defaults to localhost so isn't exposed outside container
