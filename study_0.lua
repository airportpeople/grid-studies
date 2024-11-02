-- grid switch
-- brightness changes with tempo
-- TODO: (issue with sequential presses) use metatable of all grid cells
-- TODO: change syntax to "cell" instead of "pixel"

g = grid.connect() -- 'g' represents a connected grid



function init()
  brightness = 15 -- brightness = full bright!
  brightness_last = 0

  show = {
    last = {x = 2, y = 2},
    curr = {x = 1, y = 1}
  }

  grid_dirty = true -- initialize with a redraw
  clock.run(grid_redraw_clock) -- start the grid redraw clock

  track_tempo = true
end

function grid_pixel_fade()
  for i=brightness,0,-1 do
    brightness_last = i
    clock.sleep(0.1)
    grid_dirty = true
  end
end

-- function tempo_tracker()
--   while track_tempo do
    
--     clock.sync(1)
--   end
-- end

function grid_redraw_clock() -- our grid redraw clock
  while true do -- while it's running...
    clock.sleep(1/30) -- refresh at 30fps.
    if grid_dirty then -- if a redraw is needed...
      grid_redraw() -- redraw...
      grid_dirty = false -- then redraw is no longer needed.
    end
  end
end

function grid_redraw() -- how we redraw
  g:all(0) -- turn off all the LEDs
  g:led(show.curr.x,show.curr.y,brightness) -- light this coordinate at indicated brightness
  g:led(show.last.x,show.last.y,brightness_last)
  g:refresh() -- refresh the hardware to display the new LED selection
end

function g.key(x,y,z) -- define what happens if a grid key is pressed or released
  if z==1 then -- if a grid key is pressed down...
    show.last = {x = show.curr.x, y = show.curr.y}
    show.curr.x = x -- update stored x position to selected x position
    show.curr.y = y -- update stored y position to selected y position
    clock.run(grid_pixel_fade)
    grid_dirty = true -- flag for a redraw
  end
end

function enc(n,d) -- define what happens in an encoder is turned
  if n==3 then -- if encoder 3 is turned...
    brightness = util.clamp(brightness + d,0,15) -- inc/dec brightness
    grid_dirty = true -- flag for a redraw
  end
end