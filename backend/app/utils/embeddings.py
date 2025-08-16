from sentence_transformers import SentenceTransformer
import numpy as np
from typing import List, Union
import logging

logger = logging.getLogger(__name__)

class SentenceTransformerEmbeddings:
    def __init__(self, model_name: str = "all-MiniLM-L6-v2"):
        """Initialize the embedding model.
        
        Args:
            model_name: The name of the model to use. Default is 'all-MiniLM-L6-v2',
                      which provides a good balance between performance and speed.
                      Other options include:
                      - 'all-mpnet-base-v2' (better but slower)
                      - 'multi-qa-MiniLM-L6-cos-v1' (optimized for question-answering)
                      - 'paraphrase-multilingual-MiniLM-L12-v2' (multilingual support)
        """
        logger.info(f"Loading Sentence Transformer model: {model_name}")
        self.model_name = model_name
        self.model = SentenceTransformer(model_name)
    
    def __call__(self, input: Union[str, List[str]]) -> List[List[float]]:
        """Generate embeddings for the input text(s)."""
        if isinstance(input, str):
            input = [input]
        
        # Generate embeddings
        embeddings = self.model.encode(input, convert_to_tensor=False)
        return embeddings.tolist()
    
    def name(self) -> str:
        """Return the name of the embedding function"""
        return f"sentence-transformer-{self.model_name}"
