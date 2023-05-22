/// Prints `Hello, {name}!` in the console.
#[cfg(feature = "custom_hello")]
fn print_hello_world(name: String) {
    println!("Hello, {name}!");
}