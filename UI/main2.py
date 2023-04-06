import flet as ft
from flet import AppBar, ElevatedButton, Page, Text, View, colors, FilledButton
from get_lines import get_lines
import cv2
from io import BytesIO
import base64

def main(page :ft.Page):

    # def select_image(event):
    #     file_picker = ft.FilePicker(on_result=on_file_picker_res)
    #     file_picker.pick_files(dialog_title="Select a image", file_type=ft.FilePickerFileType.IMAGE, allow_multiple=False)
    #     return

    lines = None

    def on_back_click(e):
        view_pop(None)
        return
    
    def on_ok_click(e):
        print("Ok clicked")

    def on_file_picker_res(event: ft.FilePickerResultEvent):
        print("Selected files:", event.files[0].path)
        img, lines, output = get_lines(event.files[0].path)
        is_success, buffer = cv2.imencode(".png", img)
        img_byt = BytesIO(buffer)
        is_success, buffer = cv2.imencode(".png", output)
        output_byt = BytesIO(buffer)
        img_b64 = base64.b64encode(img_byt.getvalue()).decode("utf-8")
        output_b64 = base64.b64encode(output_byt.getvalue()).decode("utf-8")

        page.go("/upload/prview")
        page.views[-1] = View(
                    "/upload/prview",
                    [
                        ft.Column(
                            [
                                ft.Row(
                                    [
                                        Text(value="Input image", color="black"),
                                        Text(value="Expect image", color="black"),
                                    ],
                                    alignment=ft.MainAxisAlignment.SPACE_AROUND,
                                ),
                                ft.Row(
                                    [
                                        ft.Image(
                                            src_base64=img_b64,
                                        ),
                                        ft.Image(
                                            src_base64=output_b64,
                                        ),
                                    ],
                                    alignment=ft.MainAxisAlignment.SPACE_AROUND
                                ),
                                ft.Row([
                                    FilledButton("Close", on_click=on_back_click),
                                    FilledButton("OK", on_click=on_ok_click)
                                ],alignment=ft.MainAxisAlignment.SPACE_AROUND)
                            ],
                            alignment=ft.MainAxisAlignment.START
                        )
                    ],
                    horizontal_alignment = ft.CrossAxisAlignment.CENTER,
                    vertical_alignment = ft.MainAxisAlignment.CENTER,
                )
        page.update()
        return

    def view_pop(e):
        # print("View pop:", e.view)
        page.views.pop()
        top_view = page.views[-1]
        page.go(top_view.route)
    
    def route_change(e):
        page.views.clear()
        # page.views.horizontal_alignment = ft.CrossAxisAlignment.CENTER
        # page.views.vertical_alignment = ft.MainAxisAlignment.CENTER
        file_picker = ft.FilePicker(on_result=on_file_picker_res)
        page.views.append(
                View(
                    "/",
                    [
                        file_picker,
                        Text(value="Upload a image to start", color="black"),
                        FilledButton("Select a image", icon="cloud_upload", on_click=lambda _:file_picker.pick_files(dialog_title="Select a image", file_type=ft.FilePickerFileType.IMAGE, allow_multiple=False))
                    ],
                    horizontal_alignment = ft.CrossAxisAlignment.CENTER,
                    vertical_alignment = ft.MainAxisAlignment.CENTER,
                )
            )
        if page.route == "/upload":
            page.views.append(
                View(
                    "/upload",
                    [
                        file_picker,
                        Text(value="Upload a image to start", color="black"),
                        FilledButton("Select a image", icon="cloud_upload", on_click=lambda _:file_picker.pick_files(dialog_title="Select a image", file_type=ft.FilePickerFileType.IMAGE, allow_multiple=False))
                    ],
                    horizontal_alignment = ft.CrossAxisAlignment.CENTER,
                    vertical_alignment = ft.MainAxisAlignment.CENTER,
                )
            )
        if page.route == "/upload/prview":
            page.views.append(
                View(
                    "/upload/prview",
                    [
                    ]
                )
            )
        page.update()
        return
    
    page.on_route_change = route_change
    page.on_view_pop = view_pop
    
    page.go("/upload")
    
    return

ft.app(target=main, assets_dir="./")