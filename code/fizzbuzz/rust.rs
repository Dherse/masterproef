fn main() {
    for i in 1..=100 {
        print!("{i}\r");
        if i % 3 == 0 {
            print!("Fizz");
        }
        if i % 5 == 0 {
            print!("Buzz");
        }
        println!();
    }
}