from flask import Flask, jsonify
from flask import request
from etch_a_sketch import *
import serial
from serial.tools.list_ports import *
import time
import cv2

device:serial.Serial = None

app = Flask(__name__)

@app.route('/', methods=["GET"])
def get_server():
    return_data = {
        'status': True,
        'msg': 'connected to server'
    }
    return jsonify(return_data)

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
    return jsonify(return_data)

@app.route('/connect', methods=["GET"])
def connect():
    global device
    return_data = {
        'status': False,
        'msg': ''
    }
    port = request.args.get("device")
    if device is None:
        device, msg = connect_serial_port(port)
    else:
        device = None
        if port == 'disconnect':
            return_data['status'] = True
            msg = 'disconnected'
        else:
            device.close()
            device, msg = connect_serial_port(port)
    if device:
        return_data['status'] = True
    return_data['msg'] = msg
    return jsonify(return_data)

@app.route('/connect/gcode', methods=["GET"])
def send_Gcode():
    return_data = {
        'status': False,
        'msg' : ''
    }
    g_code = request.args.get("code", type=str)
    if g_code is None:
        return_data['msg'] = 'need G-code'
        
    msg = send_gcode(device, g_code, debug=False)
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


