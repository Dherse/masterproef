use std::fmt::Write;

fn main() {
    for i in 1..=100 {
        let out = format!(
            "{}{}",
            if i % 3 == 0 { "Fizz" } else { "" },
            if i % 5 == 0 { "Buzz" } else { "" }
        );
        

        if out.len() == 0 {
            println!("{i}");
        } else {
            println!("{out}");
        }
    }
}