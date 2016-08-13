###*
# Create by gitbong
# github:gitbong
###

class Timeline
	_totalFrame: 0
	_framerate: 30
	_currframe: 1
	_targetframe: 1
	_timer: -1

	_playType: 1

	_evtMap: {}

	loop: false

	constructor: (totalFrame, framerate = 30) ->
		@_totalFrame = totalFrame
		@_framerate = 1000 / framerate

		@_evtMap = {}


		@__defineGetter__('totalFrame', ->return @_totalFrame)
		@__defineSetter__('totalFrame', -> throw "totalFrame read only")

		@__defineGetter__('currentFrame', ->return @_currframe)
		@__defineSetter__('currentFrame', -> throw "currentFrame read only")

		@_render(1)

	on: (evt, fn)->
		if @_evtMap[evt] is undefined
			@_evtMap[evt] = []
		@_evtMap[evt].push fn

	_trigger: (evt)->
		arr = @_evtMap[evt]
		if(arr is undefined ) then arr = []
		for i in arr
			if typeof i is "function" then i({currFrame: @currentFrame, totalFrame: @totalFrame})

	nextFrame: ->
		@_currframe++
		#		console.log @_currframe
		if @_currframe is @_totalFrame + 1 and @loop is true
			console.log 1
			@_currframe = 1
		else
			@_currframe = @_frame(@_currframe)

		@_trigger('playing')
		@_render(@_currframe)

	prevFrame: ->
		@_currframe--
		@_currframe = @_frame(@_currframe)

		@_trigger('playing')
		@_render(@_currframe)

	play: ->
		_this = @
		@_playType = 1
		@stop()
		@_targetframe = @_totalFrame

		@_timer = setTimeout(->
			_this.play()
			_this.nextFrame()
		, @_framerate)

	playTo: (frame)->
		_this = @
		@_playType = 2
		@stop()
		@_targetframe = @_frame(frame)

		@_timer = setTimeout(->
			_this.playTo(frame)
			if _this._targetframe < _this._currframe
				_this.prevFrame()
			else if _this._targetframe > _this._currframe
				_this.nextFrame()
		, @_framerate)

	stop: ->
		clearTimeout(@_timer)

	gotoAndPlay: (frame)->
		@_currframe = @_frame(frame)
		@_render(@_currframe)
		@stop()
		@play()

	gotoAndStop: (frame)->
		@_currframe = @_frame(frame)
		@_render(@_currframe)
		@stop()

	_frame: (frame)->
		if frame > @totalFrame then frame = @totalFrame
		if frame < 1 then frame = 1
		return frame

	_render: (frame) ->
#		console.log 'frame:', frame, @totalFrame
		if @loop
			if(frame is @_totalFrame and @_playType is 1)
				@_currframe = 0
		else
			if(frame is @_targetframe) then @stop()

class MovieClip extends Timeline
	_dom: -1
	_ctx: -1
	_imgs: []
	constructor: (@libs, @width, @height, framerate = 30, @initedFn)->
		super libs.length, framerate
		@_dom = document.createElement('canvas')
		@_dom['width'] = @width
		@_dom['height'] = @height
		@_ctx = @_dom.getContext('2d')

		@__defineGetter__('dom', ->return @_dom)

		@_loadLibs()

	_loadLibs: ()->
		_this = @
		id = @_imgs.length
		if id is @libs.length
			@_render(1)
			if typeof @initedFn is "function" then @initedFn()
		else
			@_loadImg(@libs[id], (img)->
				_this._imgs.push img
				_this._loadLibs()
			)

	_loadImg: (url, fn)->
		img = new Image
		img.onload = ->
			if typeof fn is "function" then fn(img)
		img.src = url


	_render: (frame)->
		if @_ctx.drawImage
			@_ctx.drawImage(@_imgs[frame - 1], 0, 0, @width, @height)
		super frame


window.gbTimeline = Timeline
window.gbMovieClip = MovieClip