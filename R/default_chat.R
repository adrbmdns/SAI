#' Get or create the default chat object
#' @return A Chat object. 
#' @export
get_default_chat <- function() {
  default_chat <- ellmer::chat_openai()
  return(default_chat)
}