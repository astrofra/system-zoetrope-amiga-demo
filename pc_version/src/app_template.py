__author__ = 'scorpheus'

import gs


class AppTemplate:
	def __init__(self):

		# create the renderer
		self.renderer = gs.EglRenderer()
		self.renderer_async = gs.GpuRendererAsync(self.renderer)

		# create the render system, which is used to draw through the renderer
		self.render_system = gs.RenderSystem(self.renderer)
		self.render_system_async = gs.RenderSystemAsync(self.render_system)

		# create the sound manager
		self.mixer_async = gs.MixerAsync(gs.ALMixer())

		self.scene = None

		self.clock = gs.Clock()

	def __del__(self):
		self.scene.Dispose()
		self.render_system_async.Free().wait()
		self.renderer_async.Close().wait()

	def open_window(self, width, height):
		# open a window and initialize the render_system
		self.renderer_async.Open(width, height)
		self.render_system_async.Initialize().wait()

		# set the window handle to the input system
		gs.GetInputSystem().SetHandle(self.renderer.GetCurrentOutputWindow().GetHandle())

	def setup_scene(self):
		self.scene = gs.Scene()
		self.scene.SetupCoreSystemsAndComponents(self.render_system)

	def add_callback_on_frame_complete(self, on_frame_complete):
		# add a callback if the user want to draw with the rendersystem manually
		self.scene.GetRenderSignals().frame_complete_signal.Connect(on_frame_complete)

	def run(self, update=None):
		self.clock.Update()

		# Read-only
		self.scene.Update(gs.time(1.0/60.0))

		if update is not None:
			update()

		self.scene.WaitUpdate()

		# Read/write
		self.scene.Commit()
		self.scene.WaitCommit()

		if self.scene.IsReady():
			self.renderer_async.ShowFrame()

		self.renderer_async.UpdateOutputWindow()
		gs.GetInputSystem().Update()

		return self.renderer.GetDefaultOutputWindow()
