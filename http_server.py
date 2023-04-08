from flask import Flask
from flask import request
from etch_a_sketch import *
import serial
from serial.tools.list_ports import *
import time
import cv2

device = None

app = Flask(__name__)

@app.route('/', methods=["GET"])
def get_server():
    return_data = {
        'status': True,
        'msg': 'connected to server'
    }
    return return_data

@app.route('/devices', methods=["GET"])
def get_devices():
    return_data = {
        'status': False,
        'devices': [],
        'msg': 'no devices available'
    }
    return_data['status'], return_data['devices'] = get_available_ports()
    if return_data['status'] == True:
        return_data['msg'] = 'choose a device'
    return return_data

@app.route('/connect', methods=["GET"])
def connect():
    return_data = {
        'status': False,
        'msg': ''
    }
    if device is None:
        port = request.args.get("device")
        device, msg = connect_serial_port(port)
    if device:
        return_data['status'] = True
    return_data['msg'] = msg

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


