///| 
type Symbol UInt derive(Eq, Show, Hash)

///|
enum Var {
  Sym(Symbol)
  Num(UInt)
} derive(Eq, Show)

///|
pub fn Var::from_uint(u : UInt) -> Var {
  Num(u)
}

///|
pub fn Var::to_uint(v : Var) -> UInt? {
  match v {
    Sym(_) => None
    Num(u) => Some(u)
  }
}

///|

///|
struct Subst {
  vec : Array[(Var, Id)]
}

///|
pub fn Subst::new() -> Subst {
  { vec: [] }
}

///|
pub fn Subst::insert(self : Subst, var : Var, id : Id) -> Id? {
  for idx, pair in self.vec {
    if pair.0 == var {
      let old_id = pair.1
      self.vec[idx] = (var, id)
      return Some(old_id)
    }
  }
  self.vec.push((var, id))
  None
}

///|
pub fn Subst::op_get(self : Subst, var : Var) -> Id? {
  for pair in self.vec {
    if pair.0 == var {
      break Some(pair.1)
    }
  } else {
    None
  }
}

///|
priv suberror VarParseError

///|
pub fn Var::parse(str : String) -> Var raise {
  match str {
    ['?', '#', .. x] => {
      let a : UInt = @strconv.parse(x.to_string())
      Var::from_uint(a)
    }
    ['?', .. s] => Sym(Symbol(@strconv.parse(s.to_string())))
    _ => raise VarParseError
  }
}

///|
test "subst" {
  inspect(Var::parse?("?#123"), content="Ok(Num(123))")
}
