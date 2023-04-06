from UI.main_window import Ui_mainWindow as main_window
from UI.prview import Ui_MainWindow as prview_window
from PyQt5.QtWidgets import QApplication, QMainWindow
from PyQt5.QtWidgets import QFileDialog
from PyQt5.QtGui import QPixmap, QImage
from PyQt5 import uic
import sys
import matplotlib.pyplot as plt
from  get_lines import get_lines


class Prview(QMainWindow):
    def __init__(self, img, lines, output):
        super().__init__()

        # 使用 Ui_MainWindow 类创建主窗口
        uic.loadUi("UI/prview.ui", self)
        # self.ui = prview_window()
        # self.ui.setupUi(self)
        self.cancel_button.clicked.connect(self.cancel_click)
        self.ok_button.clicked.connect(self.ok_click)
        self.lines = lines

        img_pixmap = self.load_image_from_array(img)
        self.input_image_preview.setPixmap(img_pixmap)

        output_pixmap = self.load_image_from_array(output)
        self.expect_image_preview.setPixmap(img_pixmap)

    def cancel_click(self):
        self.close()

    
    def ok_click(self):
        print("ok clicked")
        self.lines


    def load_image_from_array(self, image_array):
        # 将 numpy 数组转换为 QImage
        height, width = image_array.shape
        bytes_per_line = width
        qimage = QImage(image_array.data, width, height, bytes_per_line, QImage.Format_RGB888)

        # 将 QImage 转换为 QPixmap
        pixmap = QPixmap.fromImage(qimage)

        return pixmap



class MyWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        # 使用 Ui_MainWindow 类创建主窗口
        uic.loadUi("UI/main_window.ui", self)
        # self.ui = main_window()
        # self.ui.setupUi(self)
        self.upload_image.clicked.connect(self.upload)

    def upload(self):
        # print("Upload Clicked")

        app = QApplication(sys.argv)

        formats = ["Image files (*.bmp *.gif *.jpg *.jpeg *.png *.pbm *.pgm *.ppm *.xbm *.xpm)",
           "Bitmap files (*.bmp)",
           "GIF files (*.gif)",
           "JPEG files (*.jpg *.jpeg)",
           "PNG files (*.png)",
           "Portable Bitmap files (*.pbm *.pgm *.ppm)",
           "X Bitmap files (*.xbm)",
           "X PixMap files (*.xpm)",
           "All Files (*)"]

        # 弹出文件选择框
        options = QFileDialog.Options()
        options |= QFileDialog.DontUseNativeDialog
        file_path, _ = QFileDialog.getOpenFileName(None,"Select a image", "",";;".join(formats), options=options)
        print(file_path)
        img, lines, output = get_lines(file_path)
        plt.subplot(1, 2, 1)
        plt.imshow(img, cmap="gray")
        plt.title("Input image")
        plt.axis('off')
        plt.subplot(1, 2, 2)
        plt.imshow(output, cmap="gray")
        plt.title("Expect image")
        plt.axis('off')
        self.close()
        plt.show()
        return



if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MyWindow()
    window.show()
    app.exec_()
    
