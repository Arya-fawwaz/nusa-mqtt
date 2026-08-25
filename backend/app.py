import gradio as gr
import asyncio
from mqtt_client import mqtt_subscriber

def dummy():
    return 'AI is running'

with gr.Blocks() as demo:
    gr.Markdown('Nusa MQTT Client Running')
    btn = gr.Button('Check Status')
    out = gr.Textbox()
    btn.click(dummy, outputs=out)

demo.queue()
demo.launch(server_name='0.0.0.0', server_port=7860)
