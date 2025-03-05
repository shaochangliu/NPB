c---------------------------------------------------------------------
c---------------------------------------------------------------------
c
c  mg_data module
c
c---------------------------------------------------------------------
c---------------------------------------------------------------------

      module mg_data

c---------------------------------------------------------------------
c  Parameter lm (declared and set in "npbparams.h") is the log-base2 of 
c  the edge size max for the partition on a given node, so must be changed 
c  either to save space (if running a small case) or made bigger for larger 
c  cases, for example, 512^3. Thus lm=7 means that the largest dimension 
c  of a partition that can be solved on a node is 2^7 = 128. lm is set 
c  automatically in npbparams.h
c  Parameters ndim1, ndim2, ndim3 are the local problem dimensions. 
c---------------------------------------------------------------------

      include 'npbparams.h'

      integer nm      ! actual dimension including ghost cells for communications
     >      , maxlevel! maximum number of levels
c ... kind2 is defined in npbparams.h
      integer(kind2) one
     >      , nv      ! size of rhs array
     >      , nr      ! size of residual array

      parameter( one=1 )
      parameter( nm=2+2**lm, maxlevel=(lt_default+1) )
      parameter( nv=one*(2+2**ndim1)*(2+2**ndim2)*(2+2**ndim3) )
      parameter( nr = ((nv+nm**2+5*nm+7*lm+6)/7)*8 )

c---------------------------------------------------------------------
      integer  nx(maxlevel),ny(maxlevel),nz(maxlevel)

      character class

      integer debug_vec(0:7)

      integer m1(maxlevel), m2(maxlevel), m3(maxlevel)
      integer lt, lb
      integer(kind2) ir(maxlevel)

c---------------------------------------------------------------------
c  Grid starts and ends
c---------------------------------------------------------------------
      integer  is1, is2, is3, ie1, ie2, ie3

c ... rans_save
      double precision starts(nm)

c---------------------------------------------------------------------
c  Set at m=1024, can handle cases up to 1024^3 case
c---------------------------------------------------------------------
      integer m
c      parameter( m=1037 )
      parameter( m=nm+1 )

      logical timeron
      integer T_init, T_bench, T_psinv, T_resid, T_rprj3, T_interp,
     >        T_norm2, T_mg3P, T_resid2, T_comm3, T_last
      parameter (T_init=1, T_bench=2, T_mg3P=3,
     >        T_psinv=4, T_resid=5, T_resid2=6, T_rprj3=7,
     >        T_interp=8, T_norm2=9, T_comm3=10, T_last=10)


      end module mg_data


c---------------------------------------------------------------------
c---------------------------------------------------------------------
c
c  mg_fields module
c
c---------------------------------------------------------------------
c---------------------------------------------------------------------

      module mg_fields

c---------------------------------------------------------------------------c
c These arrays are in module because they are quite large
c and probably shouldn't be allocated on the stack.
c---------------------------------------------------------------------------c

      double precision, allocatable :: u(:),v(:),r(:)

      double precision a(0:3),c(0:3)

      end module mg_fields


c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine alloc_space

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c allocate space dynamically for field arrays
c---------------------------------------------------------------------

      use mg_data, only : nr, nv
      use mg_fields

      implicit none

      integer ios
      integer element_size

      allocate( u(nr), v(nv), r(nr),
     >          stat = ios )

      if (ios .ne. 0) then
         write(*,*) 'Error encountered in allocating space'
         stop
      endif

      ! Print the memory addresses of u, v, r
      element_size = sizeof(u(1))
         write(*,*) 'Memory address of u: start =', loc(u), ' end =',
     >      loc(u) + nr * element_size
         write(*,*) 'Memory address of v: start =', loc(v), ' end =',
     >      loc(v) + nv * element_size
         write(*,*) 'Memory address of r: start =', loc(r), ' end =',
     >      loc(r) + nr * element_size
      
      return
      end
