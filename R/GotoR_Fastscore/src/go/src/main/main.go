package main

func main() {
  return 
}

func ArrayToString(input []string) string{
  if len(input) < 1 {
    return ""
  }
  
  if len(input) == 1 {
    return input[0]
  }
  
  r := input[0]
  for i := 1; i < len(input); i++{
    r = r + "-4-1-8-9-8-" + input[i]
  }
  return r
}