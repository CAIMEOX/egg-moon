///|
struct EGraph {
  mut version : Int
  union_find : Store
  class_members : Map[Int, Array[(ENode, EClassID)]]
  hash_cons : Map[ENode, EClassID]
  work_lists : Array[EClassID]
}

///|
pub fn initialize() -> EGraph {
  {
    version: 0,
    union_find: create_store(),
    class_members: Map::new(),
    hash_cons: Map::new(),
    work_lists: Array::new(),
  }
}

///|
pub fn new_class(self : EGraph) -> EClassID {
  self.union_find.make()
}

///|
pub fn get_class_members(
  self : EGraph,
  id : EClassID
) -> Array[(ENode, EClassID)] {
  match self.class_members[id] {
    Some(classes) => classes
    None => {
      let c = []
      self.class_members[id] = c
      c
    }
  }
}

///|
pub fn add_e_node(self : EGraph, node : ENode) -> EClassID {
  let node = self.union_find.canonicalize(node)
  let id = match self.hash_cons[node] {
    Some(id) => id
    None => {
      self.version += 1
      let id = self.new_class()
      let cls = self.get_class_members(id)
      cls.append(node.children().map(fn(child) { (node, child) }).to_array())
      self.hash_cons[node] = id
      id
    }
  }
  self.union_find.find(id)
}

///|
pub fn subst(
  self : EGraph,
  pat : Query[Int],
  env : Map[String, EClassID]
) -> EClassID {
  match pat {
    Var(id) => env[id].unwrap()
    Query(sym, args) => {
      let e_node = (sym, args.map(fn { arg => self.subst(arg, env) }))
      self.add_e_node(ENode(e_node))
    }
  }
}

///|
pub fn merge(self : EGraph, a : EClassID, b : EClassID) -> Unit!Error {
  let a = self.union_find.find(a)
  let b = self.union_find.find(b)
  if a != b {
    self.version += 1
    assert_eq!(self.union_find.union(a, b), a)
    assert_eq!(self.union_find.find(a), a)
    assert_eq!(self.union_find.find(a), b)
    self.get_class_members(b).append(self.get_class_members(a))
    self.get_class_members(a).clear()
    self.work_lists.push(b)
  }
}

///|
pub fn repair(self : EGraph, id : EClassID) -> Unit!Error {
  let uses_ = self.get_class_members(id)
  let uses = uses_.copy()
  uses.clear()
  uses.each(fn {
    (p_node, p_class) => {
      self.hash_cons.remove(p_node)
      let p_node = self.union_find.canonicalize(p_node)
      self.hash_cons[p_node] = self.union_find.find(p_class)
    }
  })
  let new_uses = Map::new()
  for n in new_uses {
    let (p_node, p_class) = n
    let p_node = self.union_find.canonicalize(p_node)
    match new_uses[p_node] {
      None => ()
      Some(nd) => self.merge!(p_class, nd)
    }
    new_uses[p_node] = self.union_find.find(p_class)
  }
  self.get_class_members(self.union_find.find(id)).append(new_uses.to_array())
}

///|
pub fn rebuild(self : EGraph) -> Unit!Error {
  while not(self.work_lists.is_empty()) {
    let w = self.work_lists.map(fn { x => self.union_find.find(x) })
      |> Set::from_array
    self.work_lists.clear()
    for id in w {
      self.repair!(id)
    }
  }
}

///|
pub fn e_classes(self : EGraph) -> Map[Int, Array[ENode]] {
  let result : Map[Int, Array[ENode]] = Map::new()
  for n in self.hash_cons {
    let (node, eid) = n
    let eid = self.union_find.find(eid)
    match result[eid] {
      Some(x) => x.push(node)
      None => {
        let ls = [node]
        result[eid] = ls
      }
    }
  }
  result
}
