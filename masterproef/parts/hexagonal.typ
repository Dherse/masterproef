#let atomic-tangerine = rgb(222, 143, 110)

#let hexagonal_interconnect(side: 100pt, hex-side: 10pt, nx, ny) = [#block(
    radius: 0.01 * side,
    height: side,
    width: side,
    stroke: 0.5pt + luma(5),
    clip: true,
    {
      let place = place.with(top + left)
      let node-r = 0.05 * hex-side
      let node-s = 0.15 * node-r
      
      let interconnect-center(in-index) = {
        let euclid-rem(a, b) = calc.rem(calc.rem(a, b) + b, b)
        let (x, y) = in-index
        (
          hex-side * calc.sqrt(3) / 2 * (x * 2 + int(euclid-rem(y, 4) in (0, 3))),
          hex-side * (3 * calc.floor(y / 4) + (0, 0.5, 1.5, 2).at(calc.rem(y, 4))),
        )
      }
      
      let node-center(in-index, n-index) = {
        let in-center = interconnect-center(in-index)
        let in-radius = 0.25 * hex-side
        let flip = calc.rem(in-index.at(1), 2) != 0
        let (i, j) = n-index
        let θ = (i * 2 / 3 + if flip { -1 / 2 } else { 1 / 2 }) * calc.pi
        let δ = (2 * j - 3) * 1.5 * node-r
        (
          in-center.at(0) + in-radius * calc.cos(θ) + δ * calc.sin(θ),
          in-center.at(1) - in-radius * calc.sin(θ) + δ * calc.cos(θ),
        )
      }
      
      let node(in-index, n-index) = {
        let (x, y) = node-center(in-index, n-index)
        place(
          dx: x - node-r,
          dy: y - node-r,
          circle(radius: node-r, stroke: node-s, fill: atomic-tangerine),
        )
      }
       
      let arrow(in-index-a, n-index-a, in-index-b, n-index-b) = {
        let (ax, ay) = node-center(in-index-a, n-index-a)
        let (bx, by) = node-center(in-index-b, n-index-b)
         
        let θab = calc.atan2((bx - ax) / 1pt, (by - ay) / 1pt)
        let (x0, y0) = (ax + node-r * calc.cos(θab), ay + node-r * calc.sin(θab))
        let (x1, y1) = (bx - 2 * node-r * calc.cos(θab), by - 2 * node-r * calc.sin(θab))
         
        place(line(start: (x0, y0), end: (x1, y1), stroke: node-s))
         
        let p0 = (x1, y1)
        let p1 = (
          x1 - 0.35 * node-r * calc.cos(θab + 80deg),
          y1 - 0.35 * node-r * calc.sin(θab + 80deg),
        )
        let p2 = (
          x1 - 0.35 * node-r * calc.cos(θab - 80deg),
          y1 - 0.35 * node-r * calc.sin(θab - 80deg),
        )
        let p3 = (x1 + node-r * calc.cos(θab), y1 + node-r * calc.sin(θab))
         
        place(path(p3, p1, p0, p2, closed: true, stroke: none, fill: black))
      }
       
      let interconnect(in-index) = {
        for i in range(3) {
          if calc.rem(in-index.at(1), 2) == 1 {
            arrow(in-index, (calc.rem(i - 1, 3), 0), in-index, (i, 3))
            arrow(in-index, (calc.rem(i + 1, 3), 2), in-index, (i, 1))
          } else {
            arrow(in-index, (i, 3), in-index, (calc.rem(i - 1, 3), 0))
            arrow(in-index, (i, 1), in-index, (calc.rem(i + 1, 3), 2))
          }
        }
      }
      
      let gate(in-index-a, in-index-b, i, loc) = {
        for j in range(4) {
          node(in-index-a, (i, j))
          node(in-index-b, (i, j))
        }
        for n in range(2) {
          arrow(in-index-a, (i, 0), in-index-b, (i, 2 * n))
          arrow(in-index-a, (i, 2), in-index-b, (i, 2 * n))
          arrow(in-index-b, (i, 1), in-index-a, (i, 2 * n + 1))
          arrow(in-index-b, (i, 3), in-index-a, (i, 2 * n + 1))
        }
      }
      
      for x in range(nx) {
        for y in range(ny) {
          let loc = (x: x, y: y, nx: nx, ny: ny)
          interconnect((x, y))
          if calc.rem(y, 4) == 0 {
            gate((x, y), (x, y - 1), 0, loc)
            gate((x, y), (x, y + 1), 1, loc)
            gate((x, y), (x + 1, y + 1), 2, loc)
          }
          if calc.rem(y, 4) == 2 {
            gate((x, y), (x, y - 1), 0, loc)
            gate((x, y), (x - 1, y + 1), 1, loc)
            gate((x, y), (x, y + 1), 2, loc)
          }
        }
      }
    },
  )]

#let f(w) = block(
  radius: 0.02 * w,
  height: w,
  width: w,
  {
    let place = place.with(top + left)
    let r = 0.025 * w
    let s = 0.1 * r
    
    let θs = range(3).map(i => i * 2 * calc.pi / 3)
    let xs = range(4).map(k => (2 * k - 3) * 1.5 * r)
    let ys = (0.15 * w, 0.42 * w)
    
    let xy(ijk) = {
      let (θ, x, y) = (θs, xs, ys).zip(ijk).map(((a, i)) => a.at(i))
      (
        0.45 * w + y * calc.cos(θ) + x * calc.sin(θ),
        0.50 * w - y * calc.sin(θ) + x * calc.cos(θ),
      )
    }
    
    let node(ijk) = {
      let (x, y) = xy(ijk)
      place(
        dx: x - r,
        dy: y - r,
        circle(radius: r, stroke: 1.5 * s, fill: atomic-tangerine),
      )
    }
    
    let edge(a, b) = {
      let (ax, ay) = xy(a)
      let (bx, by) = xy(b)
      let θab = calc.atan2((bx - ax) / 1pt, (by - ay) / 1pt)
      let (x0, y0) = (ax + r * calc.cos(θab), ay + r * calc.sin(θab))
      let (x1, y1) = (bx - 2 * r * calc.cos(θab), by - 2 * r * calc.sin(θab))
       
      place(line(start: (x0, y0), end: (x1, y1), stroke: s))
      
      let p0 = (x1, y1)
      let p1 = (
        x1 - 0.35 * r * calc.cos(θab + 80deg),
        y1 - 0.35 * r * calc.sin(θab + 80deg),
      )
      let p2 = (
        x1 - 0.35 * r * calc.cos(θab - 80deg),
        y1 - 0.35 * r * calc.sin(θab - 80deg),
      )
      let p3 = (x1 + r * calc.cos(θab), y1 + r * calc.sin(θab))
       
      place(path(p3, p1, p0, p2, closed: true, stroke: none, fill: black))
    }
    
    for θ in range(3) {
      for y in range(2) {
        for x in range(4) {
          node((θ, x, y))
        }
        edge((θ, 0, y), (θ, 1, 1 - y))
        edge((θ, 0, y), (θ, 3, 1 - y))
        edge((θ, 2, y), (θ, 1, 1 - y))
        edge((θ, 2, y), (θ, 3, 1 - y))
      }
      edge((θ, 3, 0), (calc.rem(θ - 1, 3), 0, 0))
      edge((θ, 1, 0), (calc.rem(θ + 1, 3), 2, 0))
    }
  },
)