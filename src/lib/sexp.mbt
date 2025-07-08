///|
typealias @immut/list.T as L

///|
enum SExp {
  Atom(String)
  List(L[SExp])
} derive(Eq)

///|
pub fn compare(self : SExp, other : SExp) -> Int {
  if self == other {
    0
  } else {
    fn cmpList {
      (Nil : L[SExp]), (Nil : L[SExp]) => 0
      Nil, _ => -1
      _, Nil => 1
      Cons(x, xs), Cons(y, ys) => {
        let r = compare(x, y)
        if r == 0 {
          cmpList(xs, ys)
        } else {
          r
        }
      }
    }

    match (self, other) {
      (Atom(a), Atom(b)) => a.compare(b)
      (Atom(_), _) => -1
      (_, Atom(_)) => 1
      (List(a), List(b)) => cmpList(a, b)
    }
  }
}
