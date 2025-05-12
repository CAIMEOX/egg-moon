///|
let tbl : Map[String, Int] = Map::new()

///|
let strs : Array[String] = Array::new()

///|
pub fn intern(str : String) -> Int {
  match tbl[str] {
    Some(x) => x
    None => {
      let id = strs.length()
      strs.push(str)
      tbl[str] = id
      id
    }
  }
}
