from flask import Flask
import os

app = Flask(__name__)


@app.route("/")
def get_index():
    target = os.environ.get("HELLO_TARGET", "world")
    return f"Hello, {target}!"


if __name__ == "__main__":
    app.run(host="0.0.0.0")  # Note - if host not specified, defaults to localhost so isn't exposed outside container
