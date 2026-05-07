// Modified algo.typ — adds `break-after` and `line-number-start` parameters
// Original: https://github.com/platformer/typst-algorithms (MIT License)

#let _algo-id-ckey = "_algo-id"
#let _algo-comment-prefix = state("_algo-comment-prefix", [])
#let _algo-comment-styles = state("_algo-comment-styles", (:))
#let _algo-line-ckey = "_algo-line"
#let _algo-indent-level = state("_algo-indent-level", 0)
#let _algo-in-algo-context = state("_algo-in-algo-context", false)
#let _algo-comment-dicts = state("_algo-comment-dicts", (:))

#let _algo-default-keywords = (
  "if", "else", "then", "while", "for", "repeat", "do", "until",
  ":", "end", "and", "or", "not", "in", "to", "down", "let", "return", "goto",
).map(kw => {
  if kw.starts-with(regex("\w")) {
    (kw, str.from-unicode(str.to-unicode(kw.first()) - 32) + kw.slice(1))
  } else {
    (kw,)
  }
}).fold((), (acc, e) => acc + e)

#let _alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#let _numerals = "0123456789"
#let _special-characters = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
#let _alphanumerics = _alphabet + _numerals
#let _ascii = _alphanumerics + _special-characters

#let _algo-assert(condition, message: "") = {
  assert(condition, message: "algo: " + message)
}

#let _indent-guides(
  stroke, offset, indent-level, indent-size,
  row-height, block-inset, row-gutter, is-first-line, is-last-line,
) = {
  let stroke-width = stroke.thickness
  let backset = if is-first-line { 0pt } else { row-gutter / 2 }
  let stroke-length = backset + row-height + (
    if is-last-line {
      calc.min(block-inset / 2, row-height / 4)
    } else {
      row-gutter / 2
    }
  )
  for j in range(indent-level) {
    box(height: row-height, width: 0pt, align(start + top, place(
      dx: indent-size * j + stroke-width / 2 + 0.5pt + offset,
      dy: -backset,
      line(length: stroke-length, angle: 90deg, stroke: stroke)
    )))
  }
}

#let _build-algo-header(header, title, parameters) = {
  if header != none {
    header
  } else {
    set align(start)
    if title != none {
      set text(1.1em)
      if type(title) == str { underline(smallcaps(title)) } else { title }
      if parameters.len() == 0 { $()$ }
    }
    if parameters != () {
      set text(1.1em)
      $($
      for (i, param) in parameters.enumerate() {
        if type(param) == str { $italic(param)$ } else { param }
        if i < parameters.len() - 1 { [, ] }
      }
      $)$
    }
    if title != none or parameters != () { [:] }
  }
}

#let _algo-indent-guides(
  indent-guides, indent-guides-offset, content,
  line-index, num-lines, indent-level, indent-size,
  block-inset, row-gutter, main-text-styles, comment-styles, line-number-styles,
) = context {
  let id-str = str(counter(_algo-id-ckey).at(here()).at(0))
  let line-index-str = str(line-index)
  let comment-dicts = _algo-comment-dicts.final()
  let comment-content = comment-dicts.at(id-str, default: (:)).at(line-index-str, default: [])
  let row-height = calc.max(
    measure({ set text(..main-text-styles); _alphanumerics; content }).height,
    measure({ set text(..comment-styles); comment-content }).height,
    measure({ set text(..line-number-styles); _numerals }).height,
  )
  let indent-size-abs = measure(rect(width: indent-size)).width
  let block-inset-abs = measure(rect(width: block-inset)).width
  let row-gutter-abs = measure(rect(width: row-gutter)).width
  _indent-guides(
    indent-guides, indent-guides-offset, indent-level,
    indent-size-abs, row-height, block-inset-abs, row-gutter-abs,
    line-index == 0, line-index == num-lines - 1,
  )
}

#let _get-algo-lines(body) = {
  if not body.has("children") { return () }
  let text-and-whitespaces = {
    let joined-children = ()
    let temp = []
    for child in body.children {
      if child == [ ] or child == linebreak() or child == parbreak() {
        if temp != [] { joined-children.push(temp); temp = [] }
        joined-children.push(child)
      } else {
        temp += child
      }
    }
    if temp != [] { joined-children.push(temp) }
    joined-children
  }
  let text-and-breaks = text-and-whitespaces.filter(
    elem => elem != [ ] and elem != parbreak()
  )
  let lines = {
    let joined-lines = ()
    let line-parts = []
    let num-linebreaks = 0
    for elem in text-and-breaks {
      if elem == linebreak() {
        if line-parts != [] { joined-lines.push(line-parts); line-parts = [] }
        num-linebreaks += 1
        if num-linebreaks > 1 { joined-lines.push([]) }
      } else {
        line-parts += [#elem ]
        num-linebreaks = 0
      }
    }
    if line-parts != [] { joined-lines.push(line-parts) }
    joined-lines
  }
  return lines
}

#let _build-formatted-algo-lines(
  lines, strong-keywords, keywords, indent-size,
  indent-guides, indent-guides-offset, inset, row-gutter,
  main-text-styles, comment-styles, line-number-styles,
) = {
  let keyword-regex = "\b{start}(?:"
  for kw in keywords { keyword-regex += kw.trim() + "|" }
  keyword-regex = keyword-regex.replace(regex("\|$"), "")
  keyword-regex += ")\b{end}"

  let formatted-lines = ()
  for (i, line) in lines.enumerate() {
    let formatted-line = {
      show regex(keyword-regex): it => {
        if strong-keywords { strong(it) } else { it }
      }
      context {
        let indent-level = _algo-indent-level.get()
        if indent-guides != none {
          _algo-indent-guides(
            indent-guides, indent-guides-offset, line,
            i, lines.len(), indent-level, indent-size,
            inset, row-gutter, main-text-styles, comment-styles, line-number-styles,
          )
        }
        box(pad(left: indent-size * indent-level, line))
      }
      counter(_algo-line-ckey).step()
    }
    formatted-lines.push(formatted-line)
  }
  return formatted-lines
}

// Build a single table for a slice of formatted lines
#let _build-algo-table-segment(
  formatted-lines, line-offset, line-number-start,
  line-numbers, comment-prefix, row-gutter, column-gutter,
  main-text-styles, comment-styles, line-number-styles,
  id-str, comment-dicts,
) = {
  let has-comments = id-str in comment-dicts
  let num-columns = 1 + int(line-numbers) + int(has-comments)
  let align-func = {
    let alignments = ()
    if line-numbers { alignments.push(right + horizon) }
    alignments.push(left + bottom)
    if has-comments { alignments.push(left + bottom) }
    (x, _) => alignments.at(x)
  }
  let table-data = ()
  for (i, line) in formatted-lines.enumerate() {
    let global-i = i + line-offset
    if line-numbers {
      table-data.push({
        set text(..line-number-styles)
        str(global-i + 1 + line-number-start)
      })
    }
    table-data.push({ set text(..main-text-styles); line })
    if has-comments {
      let comment-content = comment-dicts.at(id-str, default: (:))
                                         .at(str(global-i), default: none)
      if comment-content == none {
        table-data.push([])
      } else {
        table-data.push({
          set text(..comment-styles)
          comment-prefix
          comment-content
        })
      }
    }
  }
  table(
    columns: num-columns,
    row-gutter: row-gutter,
    column-gutter: column-gutter,
    align: align-func,
    stroke: none,
    inset: 0pt,
    ..table-data,
  )
}

// Build algo content, splitting at break-after line numbers with pagebreak
#let _build-algo-content(
  formatted-lines, line-number-start, line-numbers,
  comment-prefix, row-gutter, column-gutter,
  main-text-styles, comment-styles, line-number-styles,
  break-after, fill, stroke, radius, inset, algo-header,
) = context {
  let id-str = str(counter(_algo-id-ckey).at(here()).at(0))
  let comment-dicts = _algo-comment-dicts.final()

  // sort break points, convert to 0-based
  let break-points = break-after.map(n => n - 1).sorted()

  // split formatted-lines into segments
  let segments = ()
  let seg-start = 0
  for bp in break-points {
    if bp < 0 or bp >= formatted-lines.len() - 1 { continue }
    segments.push((formatted-lines.slice(seg-start, bp + 1), seg-start))
    seg-start = bp + 1
  }
  segments.push((formatted-lines.slice(seg-start), seg-start))

  // emit each segment in its own block, with pagebreak between
  for (s-idx, seg-info) in segments.enumerate() {
    let (seg, offset) = seg-info
    let tbl = _build-algo-table-segment(
      seg, offset, line-number-start,
      line-numbers, comment-prefix, row-gutter, column-gutter,
      main-text-styles, comment-styles, line-number-styles,
      id-str, comment-dicts,
    )
    block(
      width: auto,
      fill: fill,
      stroke: stroke,
      radius: radius,
      inset: inset,
      outset: 0pt,
      breakable: false,
    )[
      #set align(start + top)
      #if s-idx == 0 {
        algo-header
        v(weak: true, row-gutter)
      }
      #align(left, tbl)
    ]
    if s-idx < segments.len() - 1 {
      pagebreak()
    }
  }
}

#let _assert-in-algo(message) = context {
  let is-in-algo = _algo-in-algo-context.get()
  _algo-assert(is-in-algo, message: message)
}

#let i = {
  _assert-in-algo("cannot use #i outside an algo element")
  _algo-indent-level.update(n => n + 1)
}

#let d = {
  _assert-in-algo("cannot use #d outside an algo element")
  context {
    let n = _algo-indent-level.get()
    _algo-assert(n - 1 >= 0, message: "dedented too much")
  }
  _algo-indent-level.update(n => n - 1)
}

#let no-emph(body) = {
  _assert-in-algo("cannot use #no-emph outside an algo element")
  set strong(delta: 0)
  body
}

#let comment(body, inline: false) = {
  _assert-in-algo("cannot use #comment outside an algo element")
  context {
    if inline {
      let comment-prefix = _algo-comment-prefix.get()
      let comment-styles = _algo-comment-styles.get()
      set text(..comment-styles)
      comment-prefix
      no-emph(body)
    } else {
      let id-str = str(counter(_algo-id-ckey).at(here()).at(0))
      let line-index-str = str(counter(_algo-line-ckey).at(here()).at(0))
      _algo-comment-dicts.update(comment-dicts => {
        let comments = comment-dicts.at(id-str, default: (:))
        let ongoing-comment = comments.at(line-index-str, default: [])
        let comment-content = ongoing-comment + body
        comments.insert(line-index-str, comment-content)
        comment-dicts.insert(id-str, comments)
        comment-dicts
      })
    }
  }
}

// Main algo function — same as original but with two new parameters:
//   line-number-start: int  — offset added to all displayed line numbers
//   break-after: array      — list of line numbers after which to pagebreak
#let algo(
  body,
  header: none,
  title: none,
  parameters: (),
  line-numbers: true,
  line-number-start: 0,
  strong-keywords: true,
  keywords: _algo-default-keywords,
  comment-prefix: "// ",
  indent-size: 20pt,
  indent-guides: none,
  indent-guides-offset: 0pt,
  row-gutter: 10pt,
  column-gutter: 10pt,
  inset: 10pt,
  fill: rgb(98%, 98%, 98%),
  stroke: 1pt + rgb(50%, 50%, 50%),
  radius: 0pt,
  breakable: false,
  break-after: (),
  block-align: center,
  main-text-styles: (:),
  comment-styles: ("fill": rgb(45%, 45%, 45%)),
  line-number-styles: (:),
) = {
  counter(_algo-id-ckey).step()
  counter(_algo-line-ckey).update(0)
  _algo-comment-prefix.update(comment-prefix)
  _algo-comment-styles.update(comment-styles)
  _algo-indent-level.update(0)
  _algo-in-algo-context.update(true)

  let algo-header = _build-algo-header(header, title, parameters)

  let lines = _get-algo-lines(body)
  let formatted-lines = _build-formatted-algo-lines(
    lines, strong-keywords, keywords, indent-size,
    indent-guides, indent-guides-offset, inset, row-gutter,
    main-text-styles, comment-styles, line-number-styles,
  )

  set par(justify: false)

  // build all content with header in first segment's block
  let content = _build-algo-content(
    formatted-lines, line-number-start, line-numbers,
    comment-prefix, row-gutter, column-gutter,
    main-text-styles, comment-styles, line-number-styles,
    break-after, fill, stroke, radius, inset, algo-header,
  )

  if block-align != none {
    align(block-align, content)
  } else {
    content
  }

  _algo-in-algo-context.update(false)
}
