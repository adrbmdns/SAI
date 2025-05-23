#' Match the input factor to supplied levels.
#'
#' @param .f A vector of characters or a factor.
#' @param levels The levels of the factor.
#' @param chat The chat object defined by ellmer.
#' @return A named character vector of standardised category labels, with the class `"emend_lvl_match"`.
#' The names correspond to the original messy categories, and the values are the cleaned versions.
#'
#' @examples
#' \donttest{
#' chat <- ellmer::chat_ollama(model = "llama3.1:8b", seed = 0, echo = "none")
#' emend_lvl_match(messy$country,
#'                 levels = c("Asia", "Europe", "North America", "Oceania",
#'                            "South America"),
#'                 chat = chat)
#' }
#'
#' @export
emend_lvl_match <- function(.f, levels = NULL, chat = get_default_chat()) {
  if(is.null(levels)) cli::cli_abort("Please provide the levels of the factor.")
  if(is.null(chat)) cli::cli_abort("Please provide the chat object.")

  lvls_unmatched <- setdiff(unique(.f), levels)
  lvls_intersect <- intersect(unique(.f), levels)

  chat_clone <- chat$clone(deep = TRUE)

  chat_clone$set_system_prompt(paste0(
    "You are a data cleaning assistant specializing in correcting categorical data. The correct categorical levels are: ",
    paste(levels, collapse = ", "), ". ",
    "Your task is to: ",
    "* Analyze the given category value and determine if it is a typo, abbreviation, or incorrect variant of one of the correct levels. ",
    "* Suggest the best-matching correct levels based on spelling similarity, common abbreviations, or logical meaning. ",
    "* Ensure that the corrected value belongs to the predefined correct levels. ",
    "Respond with only the corrected category name without additional explanations."
  ))

  matched <- lapply(lvls_unmatched, function(x) {
    chat_clone2 <- chat_clone$clone(deep = TRUE)
    chat_clone2$chat(paste0(
      "Now process: ", x
    ))
  })

  out <- unlist(matched)
  out[!out %in% levels] <- "Unidentified"
  dict <- stats::setNames(c(out, lvls_intersect), c(lvls_unmatched, lvls_intersect))
  structure(dict, class = c("emend_lvl_match", class(dict)))
}

#' @export
format.emend_lvl_match <- function(x, ...) {
  original <- names(x)
  converted <- unname(unclass(x))
  out <- data.frame(original, converted) |> subset(is.na(converted) | original != converted)
  out <- out[order(out$converted), ]
  rownames(out) <- NULL
  out
}

#' @export
print.emend_lvl_match <- function(x, ...) {
  print(unclass(x))
  cli::cli_h1("Converted by emend:")
  out <- format(x)
  print(out)
}

#' Match input factor to specified levels.
#' @param .f A factor.
#' @param levels The levels of the factor
#' @param chat A chat object defined by ellmer.
#' @return A factor with levels matching the provided `levels` argument.
#'
#' @examples
#' \donttest{
#' chat <- ellmer::chat_ollama(model = "llama3.1:8b", seed = 0, echo = "none")
#' emend_fct_match(messy$country, levels = c("UK", "USA", "Canada", "Australia", "NZ"), chat = chat)
#' }
#'
#' @export
emend_fct_match <- function(.f, levels = NULL, chat = get_default_chat()) {
  dict <- emend_lvl_match(.f, levels, chat)
  factor(unname(unclass(dict)[.f]), levels = levels)
}

#' Reorder the levels of the input factor in a meaningful way.
#' @param .f A vector of characters or a factor.
#' @param chat A chat object defined by ellmer.
#' @return A factor with standardized category labels.
#'
#' @examples
#' \donttest{
#' chat <- ellmer::chat_ollama(model = "llama3.1:8b", seed = 0, echo = "none")
#' emend_fct_reorder(likerts$likert1, chat = chat) |> levels()
#' }
#'
#' @export
emend_fct_reorder <- function(.f, chat = get_default_chat()) {
  if(is.null(.f)) cli::cli_abort("Please provide the input vector or factor.")
  if(!is.character(.f) && !is.factor(.f)) cli::cli_abort("Input must be a charactor vector or a factor.")
  if(is.null(chat)) cli::cli_abort("Please provide the chat object.")

  lvls <- reorder_by_llm(unique(.f), chat = chat)
  factor(.f, levels = lvls)
}

# reorder_3 replace function
reorder_by_llm <- function(lvls, chat = get_default_chat()) {
  chat_clone <- chat$clone(deep = TRUE)

  chat_clone$set_system_prompt(
    paste0(
      "You are a sentiment analysis model. Your task is to analyze the sentiment of the input sentence and provide a sentiment score. ",
      "The score should be a numerical value between -100 and 100, where: ",
      "* 100 indicates a very positive sentiment * 0 indicates a neutral sentiment * -100 indicates a very negative sentiment ",
      "Consider the overall tone of the sentence, including emotions, positivity, or negativity in the context. ",
      "Return score only."
    )
  )

  senti_scores <- lapply(lvls, function(x) {
    chat_clone$chat(paste0(
      "Now process: ", x
    ))
  })

  scores <- as.numeric(unlist(senti_scores))

  df <- data.frame(Level = lvls, Score = scores)
  df_ordered <- df[order(df$Score), ]
  return(df_ordered$Level)
}

#' Get the unique levels of messy categorical data
#'
#' The returned value is a vector.
#' The LLM will return full names instead of abbreviations.
#' You can use this functions to clean up your categorical data and obtain unique levels.
#' Double check if the output from LLM is true to your data.
#' This function is generally suitable for categories, not working well with sentences and too many categories.
#'
#' @param .f A vector of characters or a factor.
#' @param chat A chat object defined by ellmer.
#' @return A character vector of standardised category names.
#'
#' @examples
#' \donttest{
#' options(ellmer_timeout_s = 3600)
#' chat <- ellmer::chat_ollama(model = "llama3.1:8b", seed = 0, echo = "none")
#' emend_lvl_unique(messy$country, chat = chat)
#' }
#'
#' @export
emend_lvl_unique <- function(.f, chat = get_default_chat()){
  if(is.null(.f)) cli::cli_abort("Please provide the input vector or factor.")
  if(!is.character(.f) && !is.factor(.f)) cli::cli_abort("Input must be a charactor vector or a factor.")
  if(is.null(chat)) cli::cli_abort("Please provide the chat environment.")

  chat_clone <- chat$clone(deep = TRUE)

  chat_clone$set_system_prompt(paste0(
    "You are a data cleaning assistant specializing in standardizing categorical data. ",
    "You will be given a list of messy names that may contain typos, abbreviations, or inconsistencies. ",
    "Your task is to: ",
    "* Analyze the given list and determine the most likely set of correct unique categories. ",
    "* Group similar values together and infer the correct standardised categories. ",
    "* Ensure that the correct categories are in their __full names__, expanding any abbreviations where necessary. ",
    "* Return only the cleaned unique categories as a JSON array. ",
    "## Output Format: ",
    "Return the result as a JSON array with no additional text or explanations. Example format: ",
    '["Full Category Name 1", "Full Category Name 2", "Full Category Name 3"]',
    "Ensure that: ",
    "* The output contains __only__ a valid JSON array. ",
    "* Abbreviations are expanded into full names. ",
    "* The categories are standardized and free of inconsistencies."
  ))

  origin_levels <- unique(.f)

  llm_out <- chat_clone$chat(paste0(
    "Now process: ",
    paste(origin_levels, collapse = ", "), "."
  ))

  tryCatch({
    correct_categories <- jsonlite::fromJSON(llm_out)
    if (!is.vector(correct_categories) || !is.character(correct_categories)) {
      cli::cli_abort("LLM output is not a valid JSON array of strings.")
    }
  }, error = function(e) {
    cli::cli_abort("Failed to parse LLM response as JSON. Please check the model output.")
  })

  return(correct_categories)
}
