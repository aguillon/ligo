function bar(const _u : unit) is
  {
    var (x, y) := (4, 5);
    function add(const _u : unit) is (x + y);
  } with add(unit)
