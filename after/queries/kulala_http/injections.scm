; Дополнение к queries Kulala (merge): явный диапазон для инъекции JSON в теле запроса.
((json_body) @injection.content
  (#set! injection.language "json")
  (#set! injection.include-children))
