###*
# Create by gitbong
# github:gitbong
###

_startTimeStemp = 0
_resetTimeStemp = ->
	_startTimeStemp = Date.now()
_getTimeSpace = ->
	return Date.now() - _startTimeStemp

class Timeline
	_totalFrame: 0
	_framerate: 30
	_currframe: 1           # 1...n
	_targetframe: 1
	_timer: -1
	_playType: 1            # 1:play  2:playTo
	_diraction: 1           # 1:->    2:<-
	_evtMap: {}
	
	loop: false
	
	constructor: (totalFrame, fps = 30) ->
		@_totalFrame = totalFrame
		@_framerate = 1000 / fps
		
		@_evtMap = {}
		
		@__defineGetter__('totalFrame', ->return @_totalFrame)
		@__defineSetter__('totalFrame', -> throw "totalFrame read only")
		
		@__defineGetter__('currentFrame', ->return @_currframe)
		@__defineSetter__('currentFrame', -> throw "currentFrame read only")
		
		@_render(1, false)
	
	setFramerate: (fps)->
		@_framerate = 1000 / fps
	
	on: (evt, fn)->
		if @_evtMap[evt] is undefined
			@_evtMap[evt] = []
		@_evtMap[evt].push fn
	
	_trigger: (evt, timeout = false)->
		arr = @_evtMap[evt]
		if(arr is undefined ) then arr = []
		for fn in arr
			if typeof fn is "function"
				if timeout is false
					fn({event: evt, currFrame: @currentFrame, totalFrame: @totalFrame})
				else
					setTimeout(->
						fn({event: evt, currFrame: @currentFrame, totalFrame: @totalFrame})
					, 0)
	
	nextFrame: ->
		@_diraction = 1
		
		@_currframe += 1 #+ frameOffset
		
		if @_currframe is @_totalFrame + 1 and @loop is true
			@_currframe = 1
		else
			@_currframe = @_frame(@_currframe)
		
		@_render(@_currframe)
	
	prevFrame: ->
		@_diraction = 2
		
		@_currframe -= 1 #+ frameOffset
		@_currframe = @_frame(@_currframe)
		
		@_render(@_currframe)
	
	play: (_auto = false)->
		_this = @
		@_playType = 1
		@stop()
		@_targetframe = @_totalFrame
		
		if _auto is false
			_resetTimeStemp();
		
		@_timer = setTimeout(->
			_this.play(true)
			_this.nextFrame()
		, @_framerate)
		return
	
	playTo: (frame, _auto = false)->
		_this = @
		@_playType = 2
		@stop()
		@_targetframe = @_frame(frame)
		
		if _auto is false
			_resetTimeStemp();
		
		@_timer = setTimeout(->
			_this.playTo(frame, true)
			if _this._targetframe < _this._currframe
				_this.prevFrame()
			else if _this._targetframe > _this._currframe
				_this.nextFrame()
		, @_framerate)
	
	stop: ->
		clearTimeout(@_timer)
	
	gotoAndPlay: (frame)->
		@_playType = 1
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
	
	_render: (frame, trigger = true) ->
		_this = @
		if trigger
			if(frame is @_targetframe)
				_this._trigger('complete', true)
			@_trigger('playing')
		
		if @loop
			if(frame is @_totalFrame and @_playType is 1)
				@_currframe = 0
		else
			if(frame is @_targetframe)
				if(trigger) then @_trigger('complete')
				@stop()


class MovieClip extends Timeline
	_dom: -1
	_ctx: -1
	_imgs: []
	constructor: (@libs, @width, @height, fps = 30, @initedFn)->
		super libs.length, fps
		
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
			@_render(1, false)
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
	
	
	_render: (frame, trigger = true)->
		if @_ctx.drawImage
			@_ctx.drawImage(@_imgs[frame - 1], 0, 0, @width, @height)
		super frame, trigger


class FrameVideo
	fps: 0
	
	loop: false
	bufferFrame: 30
	
	_timeStemp: 0
	_currframe: 1
	_totalFrame: 0
	
	constructor: (@libs, @width, @height, fps = 30, @initedFn)->
		@fps = 1000 / fps
		@_totalFrame = @libs.length
		
		@__defineGetter__('totalFrame', ->return @_totalFrame)
		@__defineSetter__('totalFrame', -> throw "totalFrame read only")
		
		@__defineGetter__('currentFrame', ->return @_currframe)
		@__defineSetter__('currentFrame', -> throw "currentFrame read only")
	
	play: ->
	
	pause: ->
	
	stop: ->
	
	seek: (frame)->


window.gbTimeline = Timeline
window.gbMovieClip = MovieClip
window.gbFrameVideo = FrameVideo