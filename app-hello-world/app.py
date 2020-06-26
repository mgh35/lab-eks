from flask import Flask

app = Flask(__name__)


@app.route("/")
def get_index():
    return "Hello, world!"


if __name__ == "__main__":
    app.run(host="0.0.0.0")  # Note - if host not specified, defaults to localhost so isn't exposed outside container
