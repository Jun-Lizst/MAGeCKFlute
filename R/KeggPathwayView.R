KeggPathwayView=function (gene.data = NULL, cpd.data = NULL, pathway.id, species = "hsa",
                          kegg.dir = ".", cpd.idtype = "kegg",gene.idtype ="ENTREZ",
                          gene.annotpkg = NULL, min.nnodes = 3, kegg.native = TRUE,
                          map.null = TRUE, expand.node = FALSE, split.group = FALSE,
                          map.symbol = TRUE, map.cpdname = TRUE, node.sum = "sum",
                          discrete = list(gene = FALSE, cpd = FALSE), limit=list(gene=1, cpd=1),
                          bins = list(gene = 10, cpd = 10),both.dirs = list(gene = T,cpd = T),
                          trans.fun = list(gene = NULL, cpd = NULL), low = list(gene = "deepskyblue1", cpd = "blue"),
                          mid = list(gene = "gray", cpd = "gray"), high = list(gene = "red", cpd ="yellow"),
                          na.col = "transparent", ...)
{
  dtypes = !is.null(gene.data) + (!is.null(cpd.data))
  cond0 = dtypes == 1 & is.numeric(limit) & length(limit) >
    1
  if (cond0) {
    if (limit[1] != limit[2] & is.null(names(limit)))
      limit = list(gene = limit[1:2], cpd = limit[1:2])
  }
  if (is.null(trans.fun))
    trans.fun = list(gene = NULL, cpd = NULL)
  arg.len2 = c("discrete", "limit", "bins", "both.dirs", "trans.fun",
               "low", "mid", "high")
  for (arg in arg.len2) {
    obj1 = eval(as.name(arg))
    if (length(obj1) == 1)
      obj1 = rep(obj1, 2)
    if (length(obj1) > 2)
      obj1 = obj1[1:2]
    obj1 = as.list(obj1)
    ns = names(obj1)
    if (length(ns) == 0 | !all(c("gene", "cpd") %in% ns))
      names(obj1) = c("gene", "cpd")
    assign(arg, obj1)
  }
  if (is.character(gene.data)) {
    gd.names = gene.data
    gene.data = rep(1, length(gene.data))
    names(gene.data) = gd.names
    both.dirs$gene = FALSE
    ng = length(gene.data)
    nsamp.g = 1
  }else if (!is.null(gene.data)) {
    if (length(dim(gene.data)) == 2) {
      gd.names = rownames(gene.data)
      ng = nrow(gene.data)
      nsamp.g = 2
    }else if (is.numeric(gene.data) & is.null(dim(gene.data))) {
      gd.names = names(gene.data)
      ng = length(gene.data)
      nsamp.g = 1
    }else stop("wrong gene.data format!")
  }else if (is.null(cpd.data)) {
    stop("gene.data and cpd.data are both NULL!")
  }
  gene.idtype = toupper(gene.idtype)
  data(bods)
  if (species != "ko") {
    species.data = kegg.species.code(species, na.rm = T,
                                     code.only = FALSE)
  }else {
    species.data = c(kegg.code = "ko", entrez.gnodes = "0",
                     kegg.geneid = "K01488", ncbi.geneid = "")
    gene.idtype = "KEGG"
    msg.fmt = "Only KEGG ortholog gene ID is supported, make sure it looks like \"%s\"!"
    msg = sprintf(msg.fmt, species.data["kegg.geneid"])
    message("Note: ", msg)
  }
  if (length(dim(species.data)) == 2) {
    message("Note: ", "More than two valide species!")
    species.data = species.data[1, ]
  }
  species = species.data["kegg.code"]
  entrez.gnodes = species.data["entrez.gnodes"] == 1
  if (is.na(species.data["ncbi.geneid"])) {
    if (!is.na(species.data["kegg.geneid"])) {
      msg.fmt = "Only native KEGG gene ID is supported for this species,\nmake sure it looks like \"%s\"!"
      msg = sprintf(msg.fmt, species.data["kegg.geneid"])
      message("Note: ", msg)
    }else {
      stop("This species is not annotated in KEGG!")
    }
  }
  if (is.null(gene.annotpkg))
    gene.annotpkg = bods[match(species, bods[, 3]), 1]
  if (length(grep("ENTREZ|KEGG", gene.idtype)) < 1 & !is.null(gene.data)) {
    if (is.na(gene.annotpkg))
      stop("No proper gene annotation package available!")
    if (!gene.idtype %in% gene.idtype.bods[[species]])
      stop("Wrong input gene ID type!")
    gene.idmap = id2eg(gd.names, category = gene.idtype,
                       pkg.name = gene.annotpkg, unique.map = F)
    gene.data = mol.sum(gene.data, gene.idmap)
    gene.idtype = "ENTREZ"
  }
  if (gene.idtype == "ENTREZ" & !entrez.gnodes & !is.null(gene.data)) {
    message("Info: Getting gene ID data from KEGG...")
    gene.idmap = keggConv("ncbi-geneid", species)
    message("Info: Done with data retrieval!")
    kegg.ids = gsub(paste(species, ":", sep = ""), "", names(gene.idmap))
    ncbi.ids = gsub("ncbi-geneid:", "", gene.idmap)
    gene.idmap = cbind(ncbi.ids, kegg.ids)
    gene.data = mol.sum(gene.data, gene.idmap)
    gene.idtype = "KEGG"
  }
  if (is.character(cpd.data)) {
    cpdd.names = cpd.data
    cpd.data = rep(1, length(cpd.data))
    names(cpd.data) = cpdd.names
    both.dirs$cpd = FALSE
    ncpd = length(cpd.data)
  }else if (!is.null(cpd.data)) {
    if (length(dim(cpd.data)) == 2) {
      cpdd.names = rownames(cpd.data)
      ncpd = nrow(cpd.data)
    }else if (is.numeric(cpd.data) & is.null(dim(cpd.data))) {
      cpdd.names = names(cpd.data)
      ncpd = length(cpd.data)
    }else stop("wrong cpd.data format!")
  }
  if (length(grep("kegg", cpd.idtype)) < 1 & !is.null(cpd.data)) {
    data(rn.list)
    cpd.types = c(names(rn.list), "name")
    cpd.types = tolower(cpd.types)
    cpd.types = cpd.types[-grep("kegg", cpd.types)]
    if (!tolower(cpd.idtype) %in% cpd.types)
      stop("Wrong input cpd ID type!")
    cpd.idmap = cpd2kegg(cpdd.names, in.type = cpd.idtype)
    cpd.data = mol.sum(cpd.data, cpd.idmap)
  }
  warn.fmt = "Parsing %s file failed, please check the file!"
  if (length(grep(species, pathway.id)) > 0) {
    pathway.name = pathway.id
    pathway.id = gsub(species, "", pathway.id)
  }else pathway.name = paste(species, pathway.id, sep = "")
  kfiles = list.files(path = kegg.dir, pattern = "[.]xml|[.]png")
  npath = length(pathway.id)
  out.list = list()
  tfiles.xml = paste(pathway.name, "xml", sep = ".")
  tfiles.png = paste(pathway.name, "png", sep = ".")
  if (kegg.native){
    ttype = c("xml", "png")
  }else ttype = "xml"
  xml.file <- paste(kegg.dir, "/", tfiles.xml, sep = "")
  for (i in 1:npath) {
    if (kegg.native){
      tfiles = c(tfiles.xml[i], tfiles.png[i])
    }else tfiles = tfiles.xml[i]
    if (!all(tfiles %in% kfiles)) {
      dstatus = download.kegg(pathway.id = pathway.id[i],
                              species = species, kegg.dir = kegg.dir, file.type = ttype)
      if (dstatus == "failed") {
        warn.fmt = "Failed to download KEGG xml/png files, %s skipped!"
        warn.msg = sprintf(warn.fmt, pathway.name[i])
        message("Warning: ", warn.msg)
        return(invisible(0))
      }
    }
    if (kegg.native) {
      node.data = try(node.info(xml.file[i]), silent = T)
      if (class(node.data) == "try-error") {
        warn.msg = sprintf(warn.fmt, xml.file[i])
        message("Warning: ", warn.msg)
        return(invisible(0))
      }
      node.type = c("gene", "enzyme", "compound", "ortholog")
      sel.idx = node.data$type %in% node.type
      nna.idx = !is.na(node.data$x + node.data$y + node.data$width +
                         node.data$height)
      sel.idx = sel.idx & nna.idx
      if (sum(sel.idx) < min.nnodes) {
        warn.fmt = "Number of mappable nodes is below %d, %s skipped!"
        warn.msg = sprintf(warn.fmt, min.nnodes, pathway.name[i])
        message("Warning: ", warn.msg)
        return(invisible(0))
      }
      node.data = lapply(node.data, "[", sel.idx)
    }else {
      gR1 = try(parseKGML2Graph2(xml.file[i], genes = F,
                                 expand = expand.node, split.group = split.group),
                silent = T)
      node.data = try(node.info(gR1), silent = T)
      if (class(node.data) == "try-error") {
        warn.msg = sprintf(warn.fmt, xml.file[i])
        message("Warning: ", warn.msg)
        return(invisible(0))
      }
    }
    if (species == "ko"){
      gene.node.type = "ortholog"
    }else gene.node.type = "gene"
    head(gene.data)
    if ((!is.null(gene.data) | map.null) & sum(node.data$type ==
                                               gene.node.type) > 1) {
      plot.data.gene = node.map(gene.data, node.data, node.types = gene.node.type,
                                node.sum = node.sum, entrez.gnodes = entrez.gnodes)
      plot.data.gene<-plot.data.gene[rowSums(plot.data.gene[,c("x","y","width","height")])!=4,]
      kng = plot.data.gene$kegg.names
      kng.char = gsub("[0-9]", "", unlist(kng))
      if (any(kng.char > ""))
        entrez.gnodes = FALSE
      if (map.symbol & species != "ko" & entrez.gnodes) {
        if (is.na(gene.annotpkg)) {
          warn.fmt = "No annotation package for the species %s, gene symbols not mapped!"
          warn.msg = sprintf(warn.fmt, species)
          message("Warning: ", warn.msg)
        }else {
          #=====My revised===========
          #plot.data.gene$labels = eg2id(as.character(plot.data.gene$kegg.names), category = "SYMBOL", pkg.name = gene.annotpkg)[,2]
          ID2SYMBOL= bitr(as.character(plot.data.gene$kegg.names),
                          toType="SYMBOL", fromType="ENTREZID", OrgDb="org.Hs.eg.db",drop=T)
          ID2SYMBOL1=merge(plot.data.gene,ID2SYMBOL,by.x="kegg.names",by.y="ENTREZID",all.x=T,sort=F)
          plot.data.gene$labels=ID2SYMBOL1$SYMBOL
          #==========================
          mapped.gnodes = rownames(plot.data.gene)
          node.data$labels[mapped.gnodes] = plot.data.gene$labels
        }
      }
      cols.ts.gene = node.color(plot.data.gene, limit$gene,
                                bins$gene, both.dirs = both.dirs$gene, trans.fun = trans.fun$gene,
                                discrete = discrete$gene, low = low$gene, mid = mid$gene,
                                high = high$gene, na.col = na.col)
    }else plot.data.gene = cols.ts.gene = NULL
    if ((!is.null(cpd.data) | map.null) & sum(node.data$type ==
                                              "compound") > 1) {
      plot.data.cpd = node.map(cpd.data, node.data, node.types = "compound",
                               node.sum = node.sum)
      if (map.cpdname & !kegg.native) {
        plot.data.cpd$labels = cpdkegg2name(plot.data.cpd$labels)[,
                                                                  2]
        mapped.cnodes = rownames(plot.data.cpd)
        node.data$labels[mapped.cnodes] = plot.data.cpd$labels
      }
      cols.ts.cpd = node.color(plot.data.cpd, limit$cpd,
                               bins$cpd, both.dirs = both.dirs$cpd, trans.fun = trans.fun$cpd,
                               discrete = discrete$cpd, low = low$cpd, mid = mid$cpd,
                               high = high$cpd, na.col = na.col)
    }else plot.data.cpd = cols.ts.cpd = NULL
    if (kegg.native) {
      pv.pars = keggview.native(plot.data.gene = plot.data.gene,
                                cols.ts.gene = cols.ts.gene, plot.data.cpd = plot.data.cpd,
                                cols.ts.cpd = cols.ts.cpd, node.data = node.data,
                                pathway.name = pathway.name[i], kegg.dir = kegg.dir,
                                limit = limit, bins = bins, both.dirs = both.dirs,
                                discrete = discrete, low = low, mid = mid, high = high,
                                na.col = na.col, ...)
    }else {
      pv.pars = keggview.graph(plot.data.gene = plot.data.gene,
                               cols.ts.gene = cols.ts.gene, plot.data.cpd = plot.data.cpd,
                               cols.ts.cpd = cols.ts.cpd, node.data = node.data,
                               path.graph = gR1, pathway.name = pathway.name[i],
                               map.cpdname = map.cpdname, split.group = split.group,
                               limit = limit, bins = bins, both.dirs = both.dirs,
                               discrete = discrete, low = low, mid = mid, high = high,
                               na.col = na.col)
    }
    plot.data.gene = cbind(plot.data.gene, cols.ts.gene)
    if (!is.null(plot.data.gene)) {
      cnames = colnames(plot.data.gene)[-(1:8)]
      nsamp = length(cnames)/2
      if (nsamp > 1) {
        cnames[(nsamp + 1):(2 * nsamp)] = paste(cnames[(nsamp +
                                                          1):(2 * nsamp)], "col", sep = ".")
      }
      else cnames[2] = "mol.col"
      colnames(plot.data.gene)[-(1:8)] = cnames
    }
    plot.data.cpd = cbind(plot.data.cpd, cols.ts.cpd)
    if (!is.null(plot.data.cpd)) {
      cnames = colnames(plot.data.cpd)[-(1:8)]
      nsamp = length(cnames)/2
      if (nsamp > 1) {
        cnames[(nsamp + 1):(2 * nsamp)] = paste(cnames[(nsamp +
                                                          1):(2 * nsamp)], "col", sep = ".")
      }
      else cnames[2] = "mol.col"
      colnames(plot.data.cpd)[-(1:8)] = cnames
    }
    out.list[[i]] = list(plot.data.gene = plot.data.gene,
                         plot.data.cpd = plot.data.cpd)
  }
  if (npath == 1)
    out.list = out.list[[1]]
  else names(out.list) = pathway.name
  return(invisible(out.list))
}


pathPng2Pdf <- function(genelist, pathways=c(), title="Group A",
                        sub="Negative control normalized", output=".",
                        path.archive=".", kegg.native = T){
    #====No pathways supplied======================
    if(length(pathways)<1){
      p=ggplot()
      p=p+geom_text(aes(x=0,y=0,label="No enriched terms"),size=6)
      p=p+theme_void()
      print(p)
      return(0)
    }

    if(length(pathways)>4){
      keggID=pathways[1:4]
    }else{keggID=pathways}

    loginfo(paste('Starting plot kegg pathways for',sub, title))
    rownames(genelist)=genelist$ENTREZID
    p1 <- KeggPathwayView(gene.data  = genelist[,c("Control","Treatment")], pathway.id = keggID,
                          kegg.dir = path.archive, kegg.native = kegg.native)

    #Maybe there are not multi file, but only keggID.pathview.png
    pngnames=paste0(keggID, ".pathview.multi.png")
    idx = which(list.files() %in% pngnames)
    pngnames=list.files()[idx]

    boo=file.rename(from=pngnames,to=paste0(output,"/",title,"_",sub,"_",pngnames))
    originPng=paste0(keggID, ".png")
    originXML=paste0(keggID, ".xml")
    file.remove(originPng)
    file.remove(originXML)
    if(all(boo)){
      pngnames = paste0(output,"/",title,"_",sub,"_",pngnames)
    }
    thePlots <- lapply (pngnames, function(figure) {
      rasterGrob(readPNG(figure, native = FALSE),interpolate = FALSE)})
    if(length(thePlots)<4){
      for(i in (length(thePlots)+1):4){
        p1=ggplot()
        p1=p1+geom_text(aes(x=0,y=0,label="No multi pathview figures"),size=6)
        p1=p1+theme_void()
        thePlots[[i]]=p1
      }
    }
    do.call(grid.arrange, c(thePlots[1:2], ncol = 2,top=title,bottom=sub))
    do.call(grid.arrange, c(thePlots[3:4], ncol = 2,top=title,bottom=sub))
    # grid.arrange(thePlots, ncol = 2, top=title0)
}

