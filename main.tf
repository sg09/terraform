resource "random_string" "rnd" {
  length = 7
}

output "val" {
  value = random_string.rnd.result
}
