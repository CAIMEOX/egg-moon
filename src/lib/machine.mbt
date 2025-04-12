///|
struct Machine {
  reg : Array[Id]
  lookup : Array[Id]
}

///|
type Reg UInt

///|
struct Program[L] {
  instructions : Array[Instruction[L]]
  subst : Subst
}

///|
enum Instruction[L] {
  Bind(node~ : L, i~ : Reg, out~ : Reg)
  Compare(i~ : Reg, j~ : Reg)
  Lookup(term~ : Array[ENodeOrReg[L]], i~ : Reg)
  Scan(out~ : Reg)
}

///|
enum ENodeOrReg[L] {
  ENode(L)
  Reg(Reg)
}
