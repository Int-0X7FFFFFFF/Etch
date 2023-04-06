import cv2
import numpy as np

def get_lines(path):
    img = cv2.imread(path, 0)

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
    cv2.imwrite("output.jpg", canvas)

    return lines, h, w