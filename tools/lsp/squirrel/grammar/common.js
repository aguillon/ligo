module.exports = common = {
  sepBy1: (sep, p) => seq(p, repeat(seq(sep, p))),
  sepBy2: (sep, p) => seq(p, sep, common.sepBy1(sep, p)),
  sepBy: (sep, p) => optional(common.sepBy1(sep, p)),
  sepEndBy1: (sep, rule) => seq(rule, repeat(seq(sep, rule)), optional(sep)),
  sepEndBy: (sep, rule) => optional(common.sepEndBy1(sep, rule)),

  some: x => seq(x, repeat(x)),

  par: x => seq('(', x, ')'),
  brackets: x => seq('[', x, ']'),
  block: x => seq('{', x, '}'),
  chev: x => seq('<', x, '>'),

  withAttrs: ($, x) => seq(field("attributes", repeat(seq(/\[@/, $.Attr, "]"))), x),
}
