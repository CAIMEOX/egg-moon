///|
typealias EClassID = Int

///|
type ENode (Int, L[EClassID]) derive(Hash, Eq)

///|
pub fn children(self : ENode) -> L[EClassID] {
  self.1
}

///|
pub fn canonicalize(self : Store, sc : ENode) -> ENode {
  let (data, children) = sc._
  (data, children.map(fn { j => self.find(j) }))
}

///|
test "node hashes correctly" {
  let store = create_store()
  let i1 = store.make()
  let hs1 = (intern("example"), @immut/list.Cons(i1, Nil)).hash()
  let hs2 = (intern("example"), @immut/list.Cons(i1, Nil)).hash()
  inspect!(hs1 == hs2, content="true")
}

test "node hashes correctly after union" {
  let store = create_store()
  let i1 = store.make()
  let i2 = store.make()
  let hash1 = (intern("example"), @immut/list.Cons(i1, Nil)).hash()
  store.union(i1, i2) |> ignore
  let hash2 = (intern("example"), @immut/list.Cons(i1, Nil)).hash()
  inspect!(hash1 == hash2, content="true")
}
