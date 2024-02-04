use std::io;
use std::io::Write; 
use std::fs::OpenOptions;
use std::io::prelude::*;
use std::path::Path;
use rss::Channel;


fn main() {
    print!("\x1B[2J\x1B[1;1H");
    loop {
        print!("> ");
        let mut input = String::new();
        io::stdout().flush().unwrap();
        
        std::io::stdin().read_line(&mut input).unwrap();
        let input = input.trim();
        if input == "exit" {
            break;
        }

        let mut args = input.split_whitespace();
        let mut command = args.next();

        if command.is_none() {
            continue;
        }
        
        let args: Vec<&str> = args.collect();

        match command {
            Some("help") => {
                println!("Available commands:\n");
                println!("register RSS - Register a new blog\n");
                println!("unregister RSS - Unregister a blog\n");
                println!("list - List all registered blogs\n");
                println!("articles RSS - List all articles from a blog\n");
                println!("exit - Exit the program\n");
                println!("reset - Reset the list of registered blogs\n");
                println!("clear - Clear the screen\n");
            },
            Some("register") => {
                if args.len() != 2 {
                    println!("Command usage: register RSS-NAME RSS-URL");
                    continue;
                }

                let mut file;

                if !Path::new(".blogs.txt").exists() {

                    file = OpenOptions::new()
                        .write(true)
                        .create(true)
                        .open(".blogs.txt")
                        .unwrap();
                }
                
                file = OpenOptions::new()
                    .write(true)
                    .append(true)
                    .open(".blogs.txt")
                    .unwrap();

                if let Err(e) = writeln!(file, "{} rss-feed:{}", args[0], args[1]) {
                    eprintln!("Couldn't write to file: {}", e);
                }
                
                println!("Registering: {}", args[0]);
            },
            Some("unregister") => {
                if args.len() == 0 || args.len() > 1 {
                    println!("Command usage: unregister RSS-NAME");
                    continue;
                }

                let mut file;

                if !Path::new(".blogs.txt").exists() {
                    println!("File does not exist");
                    continue;
                }

                file = OpenOptions::new()
                    .read(true)
                    .open(".blogs.txt")
                    .unwrap();
                
                let mut contents = String::new();
                file.read_to_string(&mut contents).unwrap();

                let mut new_contents = String::new();
                for line in contents.lines() {
                    let line_args = line.split_whitespace().collect::<Vec<&str>>();
                    if line_args[0] != args[0] {
                        new_contents.push_str(line);
                        new_contents.push_str("\n");
                    }
                }

                file = OpenOptions::new()
                    .write(true)
                    .truncate(true)
                    .open(".blogs.txt")
                    .unwrap();
                
                if let Err(e) = writeln!(file, "{}", new_contents) {
                    eprintln!("Couldn't write to file: {}", e);
                }
                
                println!("Unregistering: {}", args[0]);
            },
            Some("list") => {
                if args.len() != 0 {
                    println!("Command usage: list");
                    continue;
                }

                println!("Listing all registered blogs");

                let mut file;

                if !Path::new(".blogs.txt").exists() {
                    println!("File does not exist");
                    continue;
                }

                file = OpenOptions::new()
                    .read(true)
                    .open(".blogs.txt")
                    .unwrap();
                
                let mut contents = String::new();

                file.read_to_string(&mut contents).unwrap();
                println!("{}", contents);
            },
            Some("reset") => {
                if args.len() != 0 {
                    println!("Command usage: reset");
                    continue;
                }

                let mut file;

                if !Path::new(".blogs.txt").exists() {
                    println!("File does not exist");
                    continue;
                }

                file = OpenOptions::new()
                    .write(true)
                    .truncate(true)
                    .open(".blogs.txt")
                    .unwrap();
            },
            Some("clear") => {
                if args.len() != 0 {
                    println!("Command usage: clear");
                    continue;
                }

                print!("\x1B[2J\x1B[1;1H");
            },
            Some("articles") => {
                if args.len() != 1 {
                    println!("Command usage: articles RSS-NAME");
                    continue;
                }

                let mut file;

                if !Path::new(".blogs.txt").exists() {
                    println!("File does not exist");
                    continue;
                }

                file = OpenOptions::new()
                    .read(true)
                    .open(".blogs.txt")
                    .unwrap();
                
                let mut contents = String::new();

                let mut rss_feed: Option<String> = None;

                file.read_to_string(&mut contents).unwrap();
                for line in contents.lines() {
                    let line_args = line.split_whitespace().collect::<Vec<&str>>();
                    if line_args[0] == args[0] {
                        let url_parts = line_args[1].split(":").collect::<Vec<&str>>();
                        // url is join parts 1 to n
                        let url = url_parts[1..].join(":");
                        rss_feed = Some(url);
                    }
                }
                
                if rss_feed.is_none() {
                    println!("Blog not found");
                    continue;
                }

                let feed_url = & rss_feed.unwrap();

                println!("Fetching articles from: {}", feed_url);

                let feed_resp = Channel::from_url(feed_url);

                if let Err(e) = feed_resp {
                    println!("Error fetching feed: {}", e);
                    println!("Error fetching feed");
                    continue;
                } 

                let feed = feed_resp.unwrap();

                let mut counter = 0; 

                for item in feed.items() {
                    println!("Title: {}", item.title().unwrap());
                    println!("Link: {}", item.link().unwrap());
                    println!("Description: {}", item.description().unwrap());
                    println!("\n");

                    counter += 1;

                    if counter == feed.items().len() {
                        break;
                    }

                    print!("(q to quit, r to read, enter to continue): ");
                    let mut input = String::new();
                    io::stdout().flush().unwrap();
                    
                    std::io::stdin().read_line(&mut input).unwrap();

                    println!();

                    let input = input.trim();
                    if input == "q" {
                        break;
                    }

                    if input == "r" {
                        // fetch the article from item.link().unwrap()
                        let article_resp = reqwest::blocking::get(item.link().unwrap());
                        
                        if let Err(e) = article_resp {
                            println!("Error fetching article: {}", e);
                            continue;
                        }

                        let article = article_resp.unwrap().text().unwrap();

                        println!("{}", article);
                    }
                }


            },
            _ => {
                println!("Invalid command");
            }
        }
    }
    print!("\x1B[2J\x1B[1;1H");
}
