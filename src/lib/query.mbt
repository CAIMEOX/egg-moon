///|
enum Query[T] {
  Var(String)
  Query(T, L[Query[T]])
}

///|
pub fn of_sexp[T](self : SExp, intern : (String) -> T) -> Query[T] {
  match self {
    Atom(s) =>
      if s.starts_with("?") {
        Var(s.substring(start=1))
      } else {
        Query(intern(s), Nil)
      }
    List(Cons(Atom(s), children)) =>
      Query(intern(s), children.map(fn { x => x.of_sexp(intern) }))
    _ => abort("of_sexp: Invalid SExp")
  }
}

///|
pub fn variables[T](self : Query[T]) -> Set[String] {
  let s = Set::new()
  fn go {
    Query::Var(sym) => s.add(sym)
    Query(_, children) => children.each(go)
  }

  go(self)
  s
}
