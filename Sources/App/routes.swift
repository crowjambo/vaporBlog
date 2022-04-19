import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    // 1
    app.post("api", "acronyms") { req -> EventLoopFuture<Acronym> in
      // 2
      let acronym = try req.content.decode(Acronym.self)
      // 3
      return acronym.save(on: req.db).map {
          // 4
          acronym
      }
    }
    
    app.get("api", "acronyms") {
      req -> EventLoopFuture<[Acronym]> in
      // 2
      Acronym.query(on: req.db).all()
    }
    
    app.get("api", "acronyms", ":acronymID") {
      req -> EventLoopFuture<Acronym> in
      // 2
      Acronym.find(req.parameters.get("acronymID"), on: req.db)
    // 3
        .unwrap(or: Abort(.notFound))
    }
    
    app.put("api", "acronyms", ":acronymID") {
      req -> EventLoopFuture<Acronym> in
      // 2
      let updatedAcronym = try req.content.decode(Acronym.self)
      return Acronym.find(
        req.parameters.get("acronymID"),
        on: req.db)
        .unwrap(or: Abort(.notFound)).flatMap { acronym in
          acronym.short = updatedAcronym.short
          acronym.long = updatedAcronym.long
          return acronym.save(on: req.db).map {
    acronym }
    } }
    
    app.delete("api", "acronyms", ":acronymID") {
      req -> EventLoopFuture<HTTPStatus> in
      // 2
      Acronym.find(req.parameters.get("acronymID"), on: req.db)
        .unwrap(or: Abort(.notFound))
        // 3
        .flatMap { acronym in
    // 4
          acronym.delete(on: req.db)
    // 5
            .transform(to: .noContent)
      }
    }
    
//http://localhost:8080/api/acronyms/search?term=OMG
    app.get("api", "acronyms", "search") {
      req -> EventLoopFuture<[Acronym]> in
      // 2
      guard let searchTerm =
        req.query[String.self, at: "term"] else {
        throw Abort(.badRequest)
      }
    // 3
      return Acronym.query(on: req.db)
        .filter(\.$short == searchTerm)
        .all()
    }
    
//http://localhost:8080/api/acronyms/search?term=Oh+My+God
    app.get("api", "acronyms", "search2") {
      req -> EventLoopFuture<[Acronym]> in
      // 2
      guard let searchTerm =
        req.query[String.self, at: "term"] else {
        throw Abort(.badRequest)
      }
    // 3
        // 1
        return Acronym.query(on: req.db).group(.or) { or in
          // 2
          or.filter(\.$short == searchTerm)
          // 3
          or.filter(\.$long == searchTerm)
        // 4
        }.all()
    }
    
    app.get("api", "acronyms", "first") {
      req -> EventLoopFuture<Acronym> in
      // 2
      Acronym.query(on: req.db)
    .first()
        .unwrap(or: Abort(.notFound))
    }
    
    //sort
    app.get("api", "acronyms", "sorted") {
      req -> EventLoopFuture<[Acronym]> in
      // 2
      Acronym.query(on: req.db)
        .sort(\.$short, .ascending)
    .all() }
    

    
}


