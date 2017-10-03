# enrichment for GroupA and GrouB genes
EnrichAB <- function(data, pvalue=0.05, enrich_method="Hypergeometric", adjust="none", filename=NULL, out.dir=".", gsea=F){
  loginfo("Enrichment analysis of GroupA and GroupB genes ...")
  gg=data

  idx1=gg$group=="up"
  genes=gg$ENTREZID[idx1]
  geneList=gg$diff
  names(geneList)=gg$ENTREZID

  #====GO_KEGG_enrichment=====
  keggA=enrichment_analysis(geneList = geneList, genes=genes, method = enrich_method,type = "KEGG", pvalueCutoff = pvalue,
                            plotTitle="KEGG: GroupA",gridColour="#e41a1c", pAdjustMethod = adjust)
  bpA=enrichment_analysis(geneList = geneList, genes=genes, method = "ORT", type = "BP", pvalueCutoff = pvalue,
                          plotTitle="BP: GroupA",gridColour="#e41a1c", pAdjustMethod = adjust)
  if(gsea){
    gseA=enrichment_analysis(geneList = geneList, genes=genes, method = "GSEA", type = "KEGG", pvalueCutoff = pvalue,
                             plotTitle="GSEA: GroupA",gridColour="#e41a1c", pAdjustMethod = adjust)
  }

  idx2=gg$group=="down"
  genes=gg$ENTREZID[idx2]
  geneList=gg$diff
  names(geneList)=gg$ENTREZID
  #====GO_KEGG_enrichment=====
  keggB=enrichment_analysis(geneList = geneList, genes=genes, method = enrich_method,type = "KEGG",pvalueCutoff = pvalue,
                            plotTitle="KEGG: GroupB",gridColour="#377eb8", pAdjustMethod = adjust)
  bpB = enrichment_analysis(geneList = geneList, genes=genes, method = "ORT",type = "BP",pvalueCutoff = pvalue,
                            plotTitle="BP: GroupB",gridColour="#377eb8", pAdjustMethod = adjust)
  if(gsea){
    gseB=enrichment_analysis(geneList = geneList, genes=genes, method = "GSEA", type = "KEGG", pvalueCutoff = pvalue,
                             plotTitle="GSEA: GroupB",gridColour="#377eb8", pAdjustMethod = adjust)
  }

  if(!is.null(filename)){
    if(gsea){
      p1=ggplot()
      p1=p1+geom_text(aes(x=0,y=0,label="No enriched terms"),size=6)
      p1=p1+theme_void()

      dir.create(file.path(out.dir,"GSEA_results"), showWarnings=FALSE)
      if(nrow(gseA$enrichRes@result)>0){
        for(term in gseA$enrichRes@result$ID[nrow(gseA$enrichRes@result):1]){
          png(file.path(out.dir,paste0("GSEA_results/GroupA_gse_", term, "_", filename,".png")),units = "in",width=400/100,height =270/100,res=300)
          p1 = gseaplot(gseA$enrichRes, term)$runningScore
          dev.off()
        }
        p1 <- p1+xlab("Ranked list of genes")+ylab("Enrichment score")
        p1 <- p1+labs(title=as.character(gseA$enrichRes@result$Description[1]))
        p1 <- p1+theme(axis.text.x=element_text(size=6, face="plain", colour='black'))
        p1 <- p1+theme(axis.text.y=element_text(size=6, face="plain", colour='black'))
        p1=p1+theme(plot.title = element_text(hjust = 0.5,size=10, face="plain", colour='black'))
        p1 <- p1+theme(panel.grid.minor=element_blank(), panel.background=element_blank())
      }
      gseA$gseaplot = p1

      if(nrow(gseB$enrichRes@result)>0){
        for(term in gseB$enrichRes@result$ID[nrow(gseB$enrichRes@result):1]){
          png(file.path(out.dir,paste0("GSEA_results/GroupB_gse_", term, "_", filename,".png")),units = "in",width=400/100,height =270/100,res=300)
          p1 = gseaplot(gseB$enrichRes, term)$runningScore
          dev.off()
        }
        p1 <- p1+xlab("Ranked list of genes")+ylab("Enrichment score")
        p1 <- p1+labs(title=as.character(gseB$enrichRes@result$Description[1]))
        p1 <- p1+theme(axis.text.x=element_text(size=6, face="plain", colour='black'))
        p1 <- p1+theme(axis.text.y=element_text(size=6, face="plain", colour='black'))
        p1=p1+theme(plot.title = element_text(hjust = 0.5,size=10, face="plain", colour='black'))
        p1 <- p1+theme(panel.grid.minor=element_blank(), panel.background=element_blank())
      }
      gseB$gseaplot = p1

      write.table(gseA$enrichRes@result, file.path(out.dir,paste0("GSEA_results/GroupA_gse_",filename,".txt")), sep="\t", row.names = F,col.names = T,quote=F)
      write.table(gseB$enrichRes@result, file.path(out.dir,paste0("GSEA_results/GroupB_gse_",filename,".txt")), sep="\t", row.names = F,col.names = T,quote=F)
    }
    write.table(keggA$enrichRes@result, file.path(out.dir,paste0("GroupA_kegg_",filename,".txt")), sep="\t", row.names = F,col.names = T,quote=F)
    write.table(bpA$enrichRes@result, file.path(out.dir,paste0("GroupA_bp_",filename,".txt")), sep="\t", row.names = F,col.names = T,quote=F)
    ggsave(keggA$gridPlot,filename=file.path(out.dir,paste0("GroupA_kegg_",filename,".png")),units = "in",width=400/100,height =270/100 )
    ggsave(bpA$gridPlot,filename=file.path(out.dir,paste0("GroupA_bp_",filename,".png")),units = "in",width=400/100,height =270/100 )

    write.table(keggB$enrichRes@result, file.path(out.dir,paste0("GroupB_kegg_",filename,".txt")), sep="\t", row.names = F,col.names = T,quote=F)
    write.table(bpB$enrichRes@result, file.path(out.dir,paste0("GroupB_bp_",filename,".txt")), sep="\t", row.names = F,col.names = T,quote=F)
    ggsave(keggB$gridPlot,filename=file.path(out.dir,paste0("GroupB_kegg_",filename,".png")),units = "in",width=400/100,height =270/100 )
    ggsave(bpB$gridPlot,filename=file.path(out.dir,paste0("GroupB_bp_",filename,".png")),units = "in",width=400/100,height =270/100 )
  }
  if(gsea){
    return(list(keggA=keggA, bpA=bpA, gseA=gseA, keggB=keggB, bpB=bpB, gseB=gseB))
  }else{
    return(list(keggA=keggA, bpA=bpA, keggB=keggB, bpB=bpB))
  }
}
