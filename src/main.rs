use rocket::fs::NamedFile;
use std::path::{Path, PathBuf};

#[macro_use]
extern crate rocket;

static FILEPATH: &str = std::env!("FILEPATH");

#[get("/<file..>")]
async fn pictures(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new(FILEPATH).join(file)).await.ok()
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![pictures])
}
