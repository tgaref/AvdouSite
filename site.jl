using Avdou

include("Utils.jl")

function setup(; sitedir = "", publicdir = "public", prefix = "")
    ctx = @context begin
        "prefix" = prefix
        "today" = today()
    end

    site = @site begin
        @sitedir sitedir
        @publicdir publicdir
        @loadtemplates "templates"
        
        @copy begin            
            @pattern p"css/*"
            @route identity
        end
            
        @copy begin
            @pattern p"content/static/*"
            @route identity
        end
        
        @copy begin            
            @pattern p"content/static/*/*"
            @route identity
        end
            
        @copy begin
            @pattern p"content/teaching/*/*" \ p"content/teaching/*/*.md"
            @route identity
        end
            
        @copy begin
            @pattern p"content/activities/*/*" \ p"content/activities/*/*.md"
            @route identity
        end

        @rule begin
            @pattern p"content/*.md" \ p"content/index.md"
            @compilers begin
                expand_shortcodes(my_shortcodes, render)
                pandoc_md_to_html
            end
            @templates begin
                ("section.html", ctx)
                ("base.html", ctx)
            end
            @route nice_route
        end
            
        @rule begin
            @pattern p"content/index.md"
            @compilers pandoc_md_to_html
            @templates begin
                ("index.html", ctx)
                ("base.html", ctx)
            end
            @route path -> joinpath(publicdir, "index.html")
        end
            
        @rule begin
            @pattern p"content/teaching/*/*.md"
            @compilers begin
                expand_shortcodes(my_shortcodes, render)
                pandoc_md_to_html
            end
            @templates begin
                ("course.html", ctx)
                ("base.html", ctx)
            end
            @route nice_route
        end
        
        @rule begin
            @pattern p"content/activities/*/*.md"
            @compilers pandoc_md_to_html
            @templates begin
                ("base.html", ctx)
            end                
            @route set_extension("html")
        end
    end
    
    build(site)
end

    #=
    mine = Mine(
        SIMPLE("content/teaching/*/*.md"),
        [filetitleminer])

    data = execute(mine, sitedir)

    The above is equivalent to the following:

    data = @mine begin
        sitedir
        :pattern = SIMPLE("content/teaching/*/*.md")
        :miners = [filetitleminer]
    end

    # Example how to use data

    titles = Vector{String}()
    for (path, ctx) in data
        if haskey(ctx, "title")
            push!(titles, ctx["title"])
        end
    end

    println(unique(titles)) # prints a list of titles

    # Let's create a new context that has a field "list"
    # that is a vector of pairs (title, path) for all
    # files in :pattern
    
    v = [(d["title"], path) for (path, d) in data] 
    cont = Context("list" => v)    
    =#


#=
    ctx = Context()
    ctx["prefix"] = prefix
    ctx["today"] = today()
    
    copies = [
        Copy(SIMPLE("css/*"), identity),
        Copy(SIMPLE("content/static/*"), identity),
        Copy(SIMPLE("content/static/*/*"), identity),
        Copy(DIFF("content/teaching/*/*", "content/teaching/*/*.md"), identity),
        Copy(DIFF("content/activities/*/*", "content/activities/*/*.md"), identity) 
    ]

    rules = [
        Rule(DIFF("content/*.md", "content/index.md"),
             [pandoc_md_to_html],
             [("section.html", ctx), (templates["base.html"], ctx)],
             nice_route),
        Rule(SIMPLE("content/index.md"), 
             [pandoc_md_to_html],
             [("index.html", ctx), ("base.html", ctx)],
             path -> joinpath(public_dir, "index.html")),

        Rule(SIMPLE("content/teaching/*/*.md"),
             [expand_shortcodes(my_shortcodes, render), pandoc_md_to_html],
             [("course.html", ctx), ("base.html", ctx)],
             nice_route),
        Rule(SIMPLE("content/activities/*/*.md"),
             [pandoc_md_to_html],
             [("base.html", ctx)],
             set_extension("html"))
    ]

    site = Site(site_dir, public_dir, templates, copies, rules)
    build(site)
    =#
