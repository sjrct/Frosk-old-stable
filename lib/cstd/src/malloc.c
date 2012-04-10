//
// malloc.c
//
// written by sjrct
//

#include <stdlib.h>
#include <fapi.h>

typedef struct block_node
{
	unsigned size;
	struct block_node * next;
} block_node;

static block_node * head = NULL;


// memory allocation, first fit alg
void* malloc(unsigned size)
{
	block_node *first, *prev;
	void *ret;
	unsigned newsize;

	// align size to qword
	if (size & 7) size = (size & ~7) + 8;
	
	if (head == NULL) {
		// this is the first call
		head = *((block_node**)(12));	// offset of heap
		head->size = *((int*)(16));	// size of heap
		head->next = head;
	} else if ((int)head == -1) {
		// list is empty
		return NULL;
	}
	
	first = prev = head;
	head = head->next;
	
	while (1) {
		if (head->size >= size)
		{
			// found block
			ret = (void*)(head + 1);
			if (head->size == size) {
				// block exactly specified size
				if (prev == head) {
					// there is nothing left...
					head = (block_node*)(-1);
				} else {
					prev->next = head->next;
					head = head->next;
				}
				return ret;
			} else {
				// block greater than specified size
				newsize = head->size - size;
				head->size = size;
				if (prev == head) {
					head += (size >> 3) + 1;
					head->next = head;
					head->size = newsize;
				} else {
					prev->next = head + (size >> 3) + 1;
					prev->next->next = head->next;
					head = prev->next;
					head->size = newsize;
				}
			}
			return ret;
		}
		
		if (head == first) break;
		head = head->next;
	}
	
	// nothing found
	return NULL;
}


// TODO reduce fragmentation
void free(void * v)
{
	block_node * freed;	
	freed = ((block_node*)v) - 1;
	freed->next = head->next;
	head->next = freed;
	head = head->next;
}
