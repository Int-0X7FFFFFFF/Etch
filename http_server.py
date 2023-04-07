from flask import Flask
from flask import request

device = None

app = Flask(__name__)

@app.route('/api/server', methods=["GET"])
def get_devices():
    return_data = {
        'status':True,
        'mag': "server online"
    }
    return return_data

@app.route('/api/devices', methods=["GET"])
def get_devices():
    return_data = {
        'status':True
    }
    return return_data

@app.route('/api/connect', methods=["GET"])
def connect():
    device_number = request.args.get("device")
    try:
        device_number = int(device_number)
    except:
        return {
        'status':False,
        'msg':'device number must be a number'
    }
    return_data = {
        'status':True,
        'msg': f'connect device {device_number} successful'
    }
    return return_data

@app.route('/api/gcode', methods=["GET"])
def send_Gcode():
    g_code = request.args.get("code")
    g_code = str(g_code)
    return_data = {
        'status':True
    }
    return return_data

@app.route('/api/image/upload', methods=["GET"])
def image_process():
    img_b64 = request.args.get("img")
    return_data = {
        'status':True
    }
    return return_data

@app.route('/api/start', methods=["GET"])
def start():
    return_data = {
        'status':True
    }
    return return_data

if __name__ == "__main__":
    app.run(debug=True)


