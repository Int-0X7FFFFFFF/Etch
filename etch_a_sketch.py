import serial
from serial.tools.list_ports import *
import time
import cv2
from get_lines import get_lines

BAUDRATE = 115200
W = 90
H = 90

def connect_serial_port(baud_rate=115200, timeout=1):
    # Get list of available serial ports
    available_ports = comports()

    # Check if any serial ports are available
    if not available_ports:
        print("No serial ports available.")
        input("Press ENTER to check available ports again...")
        return None
    else:
        # Print list of available serial ports with index numbers
        print("Available serial ports:")
        for i, port in enumerate(available_ports):
            print(f"[{i}] {port.device}")

    # Prompt user to choose a serial port by index number
    port_index = input("Enter the index number of the serial port to connect to: ")

    # Check if user's input is a valid index number
    while not port_index.isdigit() or int(port_index) < 0 or int(port_index) >= len(available_ports):
        print("Invalid index number. Please enter a valid index number.")
        port_index = input("Enter the index number of the serial port to connect to: ")

    # Get serial port name from selected index number
    port_name = available_ports[int(port_index)].device

    try:
        # Open serial port connection
        ser = serial.Serial(port=port_name, baudrate=baud_rate, timeout=timeout)
        ser.set_buffer_size(rx_size=4096, tx_size=4096)
        time.sleep(1.0)
        # set to relative motion mode
        ser.write(b"G91\n")
        response = ser.readline().decode('utf-8').rstrip()
        print(response)
        ser.write(b"G21\n")
        response = ser.readline().decode('utf-8').rstrip()
        print(response)
    except serial.SerialException:
        print("Failed to establish serial connection")
    except serial.SerialTimeoutException:
        print("Timeout occurred while waiting for response")
    except Exception as e:
        print("An error occurred:", e)
    finally:
        if ser.is_open:
            return ser
        else:
            return None

def get_available_ports():
    available_ports = comports()
    ports_available = False
    port_names = []
    for port in available_ports:
        port_names.append(port.device)
    if len(port_names) > 0:
        ports_available = True
    return ports_available, port_names

def connect_serial_port(port_name, baud_rate=115200, timeout=1):
    try:
        # Open serial port connection
        ser = serial.Serial(port=port_name, baudrate=baud_rate, timeout=timeout)
        ser.set_buffer_size(rx_size=4096, tx_size=4096)
        time.sleep(1.0)
        ser.write(b'M115\n')
        response = ser.readline().decode().strip()
        if not response.startswith('echo:Marlin'):
            return None, 'Marlin is not installed'
        # set to relative motion mode
        ser.write(b"G91\n")
        response = ser.readline().decode('utf-8').rstrip()
        ser.write(b"G21\n")
        response = ser.readline().decode('utf-8').rstrip()
    except serial.SerialException:
        msg = "Failed to establish serial connection"
    except serial.SerialTimeoutException:
        msg = "Timeout occurred while waiting for response"
    except Exception as e:
        msg = f"An error occurred: {e}"
    
    if ser.is_open:
        return ser, 'connect to the board successful'
    else:
        return None, msg

def main_menu(ser:serial.Serial):
    while True:
        print("\nChoose an option:")
        print("1. Choose a default shape to draw")
        print("2. Upload a picture to draw")
        print("3. Send a G-code file")
        print("4. Type G-code to send")
        print("5. Exit")
        option = input("Enter the option number: ")

        if option == "1":
            print("Option 1 selected. Choose a default shape to draw.")
            draw_default_shape(ser)
        elif option == "2":
            print("Option 2 selected. Upload a picture to draw.")
            file_path = input("Enter file path: ")
            draw_a_picture(ser, file_path)
        elif option == "3":
            print("Option 3 selected. Send a G-code file.")
            send_gcode_file(ser)
        elif option == "4":
            print("Option 4 selected. Type G-code to send.")
            while True:
                gcode = input("Enter GCode command (or 'exit' to return to main menu): ")
                if gcode.lower() == 'exit':
                    break
                send_gcode(ser, gcode)
        elif option == "5":
            print("Exiting program...")
            ser.close()
            exit()
        else:
            print("Invalid option. Please choose a valid option.")
            
def draw_default_shape(ser:serial.Serial):
    while True:
        print("Choose a default shape to draw:")
        print("1. Square")
        print("2. Circle")
        print("3. Star")
        print("4. Return")
        shape_choice = input("Enter your choice (1-4): ")

        if shape_choice == "1":
            file_path = "./square.gcode"
            break
        elif shape_choice == "2":
            file_path = "./circle.gcode"
            break
        elif shape_choice == "3":
            file_path = "./star.gcode"
            break
        elif shape_choice == "4":
            return
        else:
            print("Invalid choice. Please choose again.\n")

    send_gcode_file(ser, file_path)

def draw_a_picture(ser:serial.Serial, path):
    lines, h, w = get_lines(path)
    h_ratio = H / h
    w_ratio = W / w
    set_current_position_as_initial(ser)
    with open('result.gcode', 'w') as f:
        x, y = lines[0][0]
        if x == w:
            x = round(x * w_ratio, 2)
            y = round(y * h_ratio, 2)
            send_gcode(ser, point_to_g1(x, 0))
            send_gcode(ser, point_to_g1(0, y))
        else:
            x = round(x * w_ratio, 2)
            y = round(y * h_ratio, 2)
            send_gcode(ser, point_to_g1(0, y))
            send_gcode(ser, point_to_g1(x, 0))
        f.write('G90\n')
        x, y = lines[0][1]
        x = round(x * w_ratio, 2)
        y = round(y * h_ratio, 2)
        f.write(point_to_g1(x, y))
        for line in lines[1:]:
            x, y = line[1]
            x = round(x * w_ratio, 2)
            y = round(y * h_ratio, 2)
            f.write(point_to_g1(x, y))
        f.write('G91\n')
    send_gcode_file(ser, './result.gcode')

def point_to_g1(x, y):
    return f'G1 X{x} Y{y}\n'

def point_to_g0(x, y):
    return f'G0 X{x} Y{y}\n'

def set_current_position_as_initial(ser:serial.Serial):
    send_gcode(ser, 'G92 X0 Y0')

def send_gcode_file(ser:serial.Serial, file_path=None):
    if file_path is None:
        file_path = input("Enter the file path of the GCode file to send: ")
    try:
        i = 0
        with open(file_path, 'r') as f:
            for line in f:
                print(line.rstrip())
                ser.write(line.encode('utf-8'))
                response = ser.readline().decode('utf-8').strip()
                print(response)
                time.sleep(0.01)
                if response != 'ok':#== 'echo:busy: processing':
                    time.sleep(5)
    except FileNotFoundError:
        print("File not found!")

def send_gcode(ser:serial.Serial, gcode, debug=True):
        print(gcode)
        if gcode[-1] != '\n':
            gcode = gcode + '\n'
        gcode = gcode.upper()
        ser.write(gcode.encode('utf-8'))
        response = ser.readline().decode().strip()
        if debug:
            print(response)
        return response

if __name__ == "__main__":
    # main_menu(None)
    # draw_a_picture(None, './cameraman.png')
    # exit()
    while True:
        ser = connect_serial_port(BAUDRATE)
        if ser:
            main_menu(ser)
            