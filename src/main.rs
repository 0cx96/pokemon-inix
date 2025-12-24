use std::{fs::File, path::PathBuf, env, io::{self, Write}};

use clap::Parser;
use csv::Reader;
use rand::{prelude::IteratorRandom, Rng};
use viuer::{print_from_file, Config};

const TYPES: [&str; 18] = [
    "🏳️", "🔥", "🌊", "⚡", "🍃", "🌨️", "🥊", "💀", "🌎", "🐦", "🔮", "🐞", "🗿", "👻", "🐲", "🌑",
    "🔩", "🧚",
];
const INVALID_TYPE_STR: &str = "🚫";

const GENERATIONS: [(&str, &str); 10] = [
    ("1", "I Generation"),
    ("2", "II Generation"),
    ("3", "III Generation"),
    ("4", "IV Generation"),
    ("5", "V Generation"),
    ("6", "VI Generation"),
    ("7", "VII Generation"),
    ("8", "VIII Generation"),
    ("Hisui", "Hisui Region"),
    ("9", "IX Generation"),
];

/// Show Pokémons inside your terminal!
#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
pub struct ProgramArgs {
    /// pick a pokemon to show
    #[clap(short, long, value_parser)]
    pub pokemon: Option<String>,

    /// randomly choose a pokemon from the given generations
    /// currently supported generations are: [1, 2, 3, 4, 5, 6, 7, 8, Hisui, 9]
    #[clap(short, long, value_parser, num_args = 1.., value_delimiter = ',', verbatim_doc_comment)]
    #[arg(conflicts_with = "pokemon")]
    pub generations: Option<Vec<String>>,

    /// suppress the Pokémon info
    #[clap(short, long, value_parser)]
    pub quiet: bool,

    /// change the Pokémon size
    #[clap(long, default_value = "1.0", value_parser = check_scale)]
    pub scale: f32,

    /// use a fixed height for every Pokémon
    #[clap(long, value_parser = check_height)]
    #[arg(conflicts_with = "scale")]
    pub height: Option<u32>,

    /// makes the pokemon shiny
    #[clap(long, default_value = "8192", value_parser)]
    pub shiny_probability: u32,

    /// check for new pokemon icons
    #[clap(short, long, value_parser)]
    pub update: bool,
}

fn check_scale(scale: &str) -> Result<f32, String> {
    if let Ok(s) = scale.parse::<f32>() {
        if s >= 0.5 {
            return Ok(s);
        }
    }

    Err(String::from("scale factor must be at least 0.5."))
}

fn check_height(height: &str) -> Result<u32, String> {
    if let Ok(h) = height.parse::<u32>() {
        if h >= 2 {
            return Ok(h);
        }
    }

    Err(String::from("height must be at least 2."))
}

#[derive(Debug, Clone, serde::Deserialize)]
struct Pokemon {
    name: String,
    generation: String,
    height: u32,
    typing: String,
}

fn get_pokemon(pokemon_name: &str, pokemons: &[Pokemon]) -> Pokemon {
    pokemons
        .iter()
        .find(|p| p.name == pokemon_name)
        .expect("the given pokemon does not exist")
        .clone()
}

fn get_random_pokemon<R: Rng + Clone>(
    rng: &mut R,
    pokemons: &[Pokemon],
    gens: &Option<Vec<String>>,
) -> Option<Pokemon> {
    pokemons
        .iter()
        .filter(|p| {
            if let Some(gs) = &gens {
                gs.contains(&p.generation)
            } else {
                true
            }
        })
        .choose(rng)
        .cloned()
}

fn gen_label(gen: &str) -> &str {
    GENERATIONS.iter().find(|(g, _)| *g == gen).unwrap().1
}

fn handle_update() {
    println!("Checking for new icons...");
    let output = std::process::Command::new("nvchecker")
        .args(["-c", "nvchecker.toml", "--json"])
        .output();

    match output {
        Ok(output) => {
            let stdout = String::from_utf8_lossy(&output.stdout);
            if stdout.contains("\"version\"") {
                println!("\x1b[93m[!] New Pokemon icons might be available!\x1b[0m");
                print!("Would you like to run the update script now? (y/n): ");
                io::stdout().flush().unwrap();
                
                let mut input = String::new();
                io::stdin().read_line(&mut input).unwrap();
                
                if input.trim().to_lowercase() == "y" {
                    let mut child = std::process::Command::new("./update-icons.sh")
                        .spawn()
                        .expect("failed to execute update script");
                    child.wait().expect("update script failed");
                } else {
                    println!("Update skipped. You can run it later with ./update-icons.sh");
                }
            } else {
                println!("\x1b[92m[✓] Icons are already up to date!\x1b[0m");
            }
        }
        Err(_) => {
            println!("\x1b[91m[X] Error: 'nvchecker' is not installed or nvchecker.toml is missing.\x1b[0m");
            println!("Please ensure you are in the pokemon-inix directory and have nvchecker installed.");
        }
    }
}

fn main() {
    let args = ProgramArgs::parse();

    if args.update {
        handle_update();
        return;
    }

    let root_path_str = env::var("POKEMON_INIX_DATA")
        .or_else(|_| env::var("POKEMON_ICAT_DATA"))
        .expect("Neither $POKEMON_INIX_DATA nor $POKEMON_ICAT_DATA is set");
    let mut root_path = PathBuf::from(root_path_str);

    if let Some(gens) = &args.generations {
        if gens
            .iter()
            .any(|gen_arg| !GENERATIONS.iter().any(|(gen, _)| gen_arg == gen))
        {
            panic!("invalid region.");
        }
    }


    root_path.push("pokemon_data.csv");

    let pokemon_data = File::open(&root_path).expect("missing `pokemon_data.csv` file");

    let pokemons: Vec<Pokemon> = Reader::from_reader(pokemon_data)
        .deserialize()
        .map(|p| p.expect("`pokemon_data.csv` is corrupted"))
        .collect();

    // Retry logic: Try up to 10 times to find a Pokemon with an existing icon
    let max_retries = 10;
    let mut retry_count = 0;
    
    loop {
        let pokemon = if let (Some(n), None) = (&args.pokemon, &args.generations) {
            get_pokemon(n.as_str(), &pokemons)
        } else {
            let mut rng = rand::thread_rng();
            get_random_pokemon(&mut rng, &pokemons, &args.generations).unwrap()
        };

        let luck_num = rand::thread_rng().gen_range(0..args.shiny_probability);
        let is_shiny = luck_num == 0;

        // Build the path to the icon
        root_path.pop();
        root_path.push("pokemon-icons");

        if is_shiny {
            root_path.push("shiny");
        } else {
            root_path.push("normal");
        }

        root_path.push(format!("{}.png", pokemon.name));

        // Check if the icon file exists
        if !root_path.exists() {
            retry_count += 1;
            if retry_count >= max_retries {
                eprintln!("Warning: Could not find icon for any Pokemon after {} retries", max_retries);
                eprintln!("Last attempted: {}", pokemon.name);
                std::process::exit(1);
            }
            // Reset path and try again
            root_path.pop(); // Remove pokemon name
            root_path.pop(); // Remove normal/shiny
            root_path.pop(); // Remove pokemon-icons
            continue;
        }

        // Icon exists, display the Pokemon
        if !args.quiet {
            println!(
                "{} {} {}",
                if pokemon.typing.is_empty() {
                    INVALID_TYPE_STR.to_string()
                } else {
                    pokemon
                        .typing
                        .split(' ')
                        .map(|t| TYPES[t.parse::<usize>().unwrap_or(0)])
                        .collect::<String>()
                },
                pokemon.name,
                if is_shiny { "✨" } else { "" }
            );
        }

        let h = if let Some(h) = args.height {
            h
        } else {
            (pokemon.height as f32 * args.scale).round() as u32
        };

        let conf = Config {
            absolute_offset: false,
            height: Some(h),
            width: Some(h * 2), // Approximate aspect ratio for block rendering
            ..Default::default()
        };

        print_from_file(&root_path, &conf).expect("failed to show the image");

        if !args.quiet {
            println!("{}", gen_label(&pokemon.generation));
        }
        
        break;
    }
}
