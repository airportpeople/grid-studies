g = grid.connect()

function init()
  grid_dirty = true
  meter = { {} , selected = 1 }
  for x = 1,16 do
    meter[x] = {height = 0}
  end
  clock.run(grid_redraw_clock)
end

function grid_redraw_clock()
  while true do
    clock.sleep(1/30)
    if grid_dirty then
      grid_redraw()
      grid_dirty = false
    end
  end
end

function grid_redraw()
  g:all(0)
  for x = 1,16 do
    for y = 8,8-meter[x].height,-1 do
      g:led(x,y,meter.selected == x and 15 or 7)
    end
    g:led(meter.selected,8,15)
  end
  g:refresh()
end

function g.key(x,y,z)
  if z == 1 then
    meter.selected = x
    meter[x].height = 8 - y
  end
  grid_dirty = true
end

function enc(n,d)
  if n == 3 then
    meter[meter.selected].height = util.clamp(meter[meter.selected].height+d,0,7)
    grid_dirty = true
  end
end