#' @include get_coef.R
#' @rdname get_coef
#' @export
get_coef.svyolr <- function(model, ...) {
  out <- insight::get_parameters(model)
  out <- stats::setNames(out$Estimate, out$Parameter)

  return(out)
}

#' @include set_coef.R
#' @rdname set_coef
#' @export

set_coef.svyolr <- function(model, coefs, ...) {
  # in basic model classes coefficients are named vector
  idx <- match(names(model$coefficients), names(coefs))
  model[["coefficients"]] <- coefs[idx]
  idx <- match(names(model$zeta), names(coefs))
  model[["zeta"]] <- coefs[idx]
  model
}

#' @include get_group_names.R
#' @rdname get_group_names
#' @export
get_group_names.svyolr <- function(model, ...) {
  resp <- insight::get_response(model)
  if (is.factor(resp)) {
    out <- levels(resp)
  } else {
    out <- unique(resp)
  }
  return(out)
}

#' @include get_predict.R
#' @rdname get_predict
#' @export
get_predict.svyolr <- function(model,
                               newdata = insight::get_data(model),
                               type = "probs",
                               ...) {

  type <- sanitize_type(model, type, calling_function = "predictions")

  # hack: 1-row newdata returns a vector, so get_predict.default does not learn about groups
  if (nrow(newdata) == 1) {
    hack <- TRUE
    newdata <- newdata[c(1, 1), , drop = FALSE]
    newdata$rowid[1] <- -Inf
  } else {
    hack <- FALSE
  }

  out <- get_predict.default(model,
                             newdata = newdata,
                             type = type,
                             ...)

  # hack
  out <- out[out$rowid != -Inf, ]

  return(out)
}