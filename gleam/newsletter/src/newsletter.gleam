import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn read_emails(path: String) -> Result(List(String), Nil) {
  simplifile.read(path)
  |> result.map(string.trim)
  |> result.map(string.split(_, "\n"))
  |> result.nil_error()
}

pub fn create_log_file(path: String) -> Result(Nil, Nil) {
  simplifile.create_file(path)
  |> result.nil_error()
}

pub fn log_sent_email(path: String, email: String) -> Result(Nil, Nil) {
  simplifile.append(path, email <> "\n")
  |> result.nil_error()
}

pub fn send_newsletter(
  emails_path: String,
  log_path: String,
  send_email: fn(String) -> Result(Nil, Nil),
) -> Result(Nil, Nil) {
  use _ <- result.try(create_log_file(log_path))
  use emails <- result.try(read_emails(emails_path))
  list.map(emails, fn(email) {
    case send_email(email) {
      Ok(Nil) -> log_sent_email(log_path, email)
      Error(Nil) -> Error(Nil)
    }
  })
  Ok(Nil)
}
