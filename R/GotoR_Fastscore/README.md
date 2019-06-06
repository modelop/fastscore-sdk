Info about this project
===

### Reccent updates: (2019-05-29)

- Adjusted package according to recent Fastscore GoSDK changes (link: https://github.com/opendatagroup/fastscore-sdk-go/tree/master/sdk)
- Removed composer & conductor & sensor functions
- Some types conversion note: error to error-message-string, double-array to transformed-string-array


### Installation

- Download GoSDK with `go get github.com/opendatagroup/fastscore-sdk-go/sdk`
- Run `R CMD INSTALL FastscoreRSDK.tar.gz` (**NOTE:** for this to work, system needs to be able to locate the standard path for stdio.h and other utilities. For MacOS, Xcode includes a package to create links for such software to find the files.. Xcode 10 the package file is located at: /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg)
- OR use `GotoR_Fastscore.Rproj` to build and install (change GOPATH in src/Makevar if necessary)
- A dockerfile is included as an example of how to setup Go dependency and install, either from bash or from Rproj.


### Documentation

R standard documentation is done through roxygen. Generated documentation files:

- DESCRIPTION: metadata of the package
- NAMESPACE: list of all exported functions
- /man/*.Rd: information of all exported functions
- vignettes: long-form documentation
- Manual FastscoreRSDK.pdf

```
system("R CMD Rd2pdf . --title=FastscoreRSDK FastscoreRSDK --output=./FastscoreRSDK.pdf --force --no-clean --internals")
```

### Auto-convert to C: 

SWIG provides an automated conversion, where we need to build an interface file (GoToRFastscore.h is the header file generated when go build the shared library from Go to C) that looks like this:

```
%module FastscoreRSDK

%{
/* Includes the header in the wrapper code */
#include "_cgo_export.h"
%}

%include "FastscoreRSDK.h"
```
Then, we can auto-gen with SWIG:
```

swig -r GoSDK.i
```

**NOTE:** SWIG can’t handle the following type definition, so we need to delete these 2 lines when building

```
typedef float _Complex GoComplex64;
typedef double _Complex GoComplex128;
```

**NOTE:** SWIG also generated variables with name starting with '_', which is not allowed in R. We have to manually fix them by replacing the following part:

```
# Start of accessor method for _GoString_
setMethod('$', '_p__GoString_', function(x, name)

{
  accessorFuns = list('p' = `_GoString__p_get`, 'n' = `_GoString__n_get`);
  vaccessors = c('p', 'n');
  ;        idx = pmatch(name, names(accessorFuns));
  if(is.na(idx)) 
  return(callNextMethod(x, name));
  f = accessorFuns[[idx]];
  if (is.na(match(name, vaccessors))) function(...){
    f(x, ...)
  } else f(x);
}


);
# end of accessor method for _GoString_
# Start of accessor method for _GoString_
setMethod('$<-', '_p__GoString_', function(x, name, value)

{
  accessorFuns = list('p' = `_GoString__p_set`, 'n' = `_GoString__n_set`);
  ;        idx = pmatch(name, names(accessorFuns));
  if(is.na(idx)) 
  return(callNextMethod(x, name, value));
  f = accessorFuns[[idx]];
  f(x, value);
  x;
}


);
setMethod('[[<-', c('_p__GoString_', 'character'),function(x, i, j, ..., value)

{
  name = i;
  accessorFuns = list('p' = `_GoString__p_set`, 'n' = `_GoString__n_set`);
  ;        idx = pmatch(name, names(accessorFuns));
  if(is.na(idx)) 
  return(callNextMethod(x, name, value));
  f = accessorFuns[[idx]];
  f(x, value);
  x;
}


);
```
### Array-to-String convertion

(Manually) seperating combined string into lists using a (self-defined) seperator. The reason of doing this is discussed at the end. For those we need to add conversion functions to outputs that are supposed to be a list:

```
;ans = .Call(...)
ans <- StringToList(ans)
ans
```

##### Functions that need StringToList conversion:

- Get_Fleet
- Attachment_list
- Model_list
- Schema_list
- Stream_list
- Model_inspect
- Stream_inspect
- Stream_sample


### Roxygen comments 

SWIG codegen does not include these. (A lot of manual work. Any way to automate?)

```
#' @useDynLib GotoRFastscore
#' @export
#' @param
#' return
#' examples
```
### Parameter names

We may need to rename all param of all functions since the names are all auto-generated so very hard to use the function. (A lot of manual work. Any way to automate?)

### Double pointer linker?

(ERROR) Here is the real deal. SWIG does a great job of passing the double pointer as an external pointer in R

```
`Get_Fleet` = function(p0)
{
  p0 = as(p0, "character"); 
  ;ans = .Call('R_swig_Get_Fleet', p0, PACKAGE='GotoRFastscore');
  ans <- new("_p_p_char", ref=ans) ;
  
  ans
  
}
```

However, SWIG does not create the "_p_p_char" class. Issue posted to SWIG mailing list and here is the respond:

"Unfortunately the support for general c arrays is pretty limited, and I haven't done much experimentation with it. You may   be able to achieve what you're after with a lot of work on typemaps. In general the swig/R module works much better with c++ types, like vectors of strings."

Go side preparation: in C, strings are stored as character arrays, so we have to convert an array of strings to a char**, for example:

```
//export Get_Fleet
func Get_Fleet(path *C.char) **C.char{
  con := sdk.NewConnect(C.GoString(path))
  r, _ := con.Fleet()
  goResult := make([]string, len(r))
  for i := 0; i < len(r); i++{
    goResult[i] = r[i].Name + ": " + r[i].Health
  }
  cArray := C.malloc(C.size_t(len(goResult)) * C.size_t(unsafe.Sizeof(uintptr(0))))
	a := (*[1<<30 - 1]*C.char)(cArray)

  for idx, substring := range goResult {
      a[idx] = C.CString(substring)
  }

  return (**C.char)(cArray)
}
```