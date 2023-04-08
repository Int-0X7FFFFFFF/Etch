from flask import Flask
from flask import request
from etch_a_sketch import *
import serial
from serial.tools.list_ports import *
import time
import cv2
import base64
from io import BytesIO
import numpy as np

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
    global device

    return {
        'status': True,
        'msg': ''
    }
    return_data = {
        'status': False,
        'msg': ''
    }
    port = request.args.get("device")
    if device is None:
        device, msg = connect_serial_port(port)
        if device:
            return_data['status'] = True
        return_data['msg'] = msg
    else:
        if port == 'disconnect':
            device = None
            return_data['status'] = True
            return_data['msg'] = 'disconnected'
        else:
            return_data['msg'] = 'already connected'
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
    global lines
    img_b64 = request.args.get("img")
    img_buffer = base64.b64decode(img_b64)
    nparr = np.frombuffer(img_buffer, np.uint8)
    # Load the image from the numpy array
    img = cv2.imdecode(nparr, cv2.IMREAD_GRAYSCALE)
    img, lines, output = get_lines(img)
    is_success, buffer = cv2.imencode(".png", output)
    output_byt = BytesIO(buffer)
    output_b64 = base64.b64encode(output_byt.getvalue()).decode("utf-8")
    return_data = {
        'status':True,
        'msg': "ok",
        'img': output_b64,
    }
    return return_data

@app.route('/api/start', methods=["GET"])
def start():
    return_data = {
        'status':True,
        'msg':"drawing starts now"
    }
    return return_data



@app.route('/api/image/post', methods=["post"])
def image_process_post():
    global lines
    img_b64 = request.form['img']
    print(img_b64)
    img_buffer = base64.b64decode(img_b64)
    nparr = np.frombuffer(img_buffer, np.uint8)
    # Load the image from the numpy array
    img = cv2.imdecode(nparr, cv2.IMREAD_GRAYSCALE)
    img, lines, output = get_lines(img)
    is_success, buffer = cv2.imencode(".png", output)
    output_byt = BytesIO(buffer)
    output_b64 = base64.b64encode(output_byt.getvalue()).decode("utf-8")
    return_data = {
        'status':True,
        'msg': "ok",
        'img': output_b64,
    }
    return return_data



def get_lines(img):
    # img = cv2.imread(path, 0)

    dst = cv2.GaussianBlur(img,(5,5),3.0)

    edges = cv2.Canny(dst, 100, 255)

    h, w = img.shape

    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # cnt = 0

    # for con in contours:
    #     cnt += len(con)

    # print(cnt)

    init_cont = contours[0][0][0]

    if (w - init_cont[1]) > (h - init_cont[1]):
        start = (init_cont[0], w)
    else:
        start = (h, init_cont[1])


    lines = []
    for contour in contours:
        for i in range(0, contour.shape[0]):
            end = tuple(contour[i][0])
            lines.append((start, end))
            start = end
    

    canvas = np.zeros_like(img)

    for line in lines:
        cv2.line(canvas, line[0], line[1], (255, 255, 255), thickness=1)

    # 保存图片
    # cv2.imwrite("output.jpg", canvas)

    return img, lines, canvas

if __name__ == "__main__":
    app.run(debug=True, port=9333)


