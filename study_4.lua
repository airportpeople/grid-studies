-- switches with a simple playhead clock
-- K2 = back to step 1
-- K3 = go

g = grid.connect()

function init()
  grid_dirty = true
  switch = {}
  step = 1
  playing = false
  div = 1/2  -- beat division for clock

  for i = 1,16 do -- since we want rows to steal from each other, we only set up unique indices for columns
    switch[i] = {y = 8} -- equivalent to switch[i]["y"] = 8
  end
  clock.run(grid_redraw_clock)
end

function grid_redraw_clock()
  while true do
    if grid_dirty then
      grid_redraw()
      grid_dirty = false
    end
    clock.sleep(1/30)
  end
end

function grid_redraw()
  g:all(0)
  for i = 1,16 do
    g:led(i, switch[i].y, 15)
    for j = 1,8 do
      if i == step and j ~= switch[i].y then
        g:led(i, j, 3)
      end
    end
  end
  g:refresh()
end

function g.key(x,y,z)
  if z == 1 then
    switch[x].y = y
    grid_dirty = true
  end
end

function playhead()
  while true do
    clock.sync(div)
    step = util.wrap(step + 1, 1, 16)
    grid_dirty = true
  end
end

function key(n, z)
  if n == 3 and z == 1 then
    if not playing then
      play = clock.run(playhead)
      playing = true
    else
      clock.cancel(play)
      playing = false
    end
  elseif n == 2 and z == 1 then
    step = 1
    grid_dirty = true
  end
end