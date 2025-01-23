///|
enum Element {
  Root(Int)
  Link(Int)
}

///| 
struct Store {
  mut limit : Int
  content : Map[Int, Element]
}

///|
let store_count : Ref[Int] = @ref.new(0)

///|
pub fn op_get(self : Store, r : Int) -> Element {
  self.content[r].unwrap()
}

///|
pub fn op_set(self : Store, r : Int, e : Element) -> Unit {
  self.content[r] = e
}

///|
pub fn r_ref(self : Store, e : Element) -> Int {
  let l = self.limit
  self.limit = l + 1
  self.content[l] = e
  l
}

///|
pub fn make(self : Store) -> Int {
  store_count.update(fn(x) { x + 1 })
  self.r_ref(Root(store_count.val))
}

///|
pub fn find(self : Store, x : Int) -> Int {
  match self[x] {
    Root(_) => x
    Link(y) => {
      let z = self.find(y)
      if not(physical_equal(z, y)) {
        self[x] = Link(z)
      }
      z
    }
  }
}

///|
pub fn equal(self : Store, x : Int, y : Int) -> Bool {
  physical_equal(self.find(x), self.find(y))
}

///|
pub fn link(self : Store, x : Int, y : Int) -> Int {
  if physical_equal(x, y) {
    x
  } else {
    match (self[x], self[y]) {
      (Root(_), Root(_)) => {
        self[x] = Link(y)
        y
      }
      _ => abort("Cannot link non-roots")
    }
  }
}

///|
pub fn union(self : Store, x : Int, y : Int) -> Int {
  let x = self.find(x)
  let y = self.find(y)
  self.link(x, y)
}

///|
pub fn create_store() -> Store {
  { limit: 0, content: Map::new() }
}
