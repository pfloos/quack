subroutine unrestricted_oscillator_strength(nBas,nC,nO,nV,nR,nS,nSa,nSb,nSt,dipole_int_aa,dipole_int_bb,Omega,XpY,XmY,os)

! Compute linear response

  implicit none
  include 'parameters.h'

! Input variables


  integer,intent(in)            :: nBas
  integer,intent(in)            :: nC(nspin)
  integer,intent(in)            :: nO(nspin)
  integer,intent(in)            :: nV(nspin)
  integer,intent(in)            :: nR(nspin)
  integer,intent(in)            :: nS(nspin)
  integer,intent(in)            :: nSa
  integer,intent(in)            :: nSb
  integer,intent(in)            :: nSt
  double precision              :: dipole_int_aa(nBas,nBas,ncart)
  double precision              :: dipole_int_bb(nBas,nBas,ncart)
  double precision,intent(in)   :: Omega(nSt)
  double precision,intent(in)   :: XpY(nSt,nSt)
  double precision,intent(in)   :: XmY(nSt,nSt)

! Local variables

  logical                       :: debug = .false.
  integer                       :: ia,jb,i,j,a,b
  integer                       :: ixyz

  double precision,allocatable  :: f(:,:)

! Output variables

  double precision              :: os(nSt)

! Memory allocation

  allocate(f(nSt,ncart))

! Initialization
   
  f(:,:) = 0d0

! Compute dipole moments and oscillator strengths

  do ia=1,nSt
    do ixyz=1,ncart

      jb = 0
      do j=nC(1)+1,nO(1)
        do b=nO(1)+1,nBas-nR(1)
          jb = jb + 1
          f(ia,ixyz) = f(ia,ixyz) + dipole_int_aa(j,b,ixyz)*XpY(ia,jb)
        end do
      end do

      jb = 0
      do j=nC(2)+1,nO(2)
        do b=nO(2)+1,nBas-nR(2)
          jb = jb + 1
          f(ia,ixyz) = f(ia,ixyz) + dipole_int_bb(j,b,ixyz)*XpY(ia,nSa+jb)
        end do
      end do

    end do
  end do

  do ia=1,nSt
    os(ia) = 2d0/3d0*Omega(ia)*sum(f(ia,:)**2)
  end do
    
  if(debug) then

    write(*,*) '------------------------'
    write(*,*) ' Dipole moments (X Y Z) '
    write(*,*) '------------------------'
    call matout(nS,ncart,f)
    write(*,*)

    write(*,*) '----------------------'
    write(*,*) ' Oscillator strengths '
    write(*,*) '----------------------'
    call matout(nS,1,os)
    write(*,*)

  end if

end subroutine unrestricted_oscillator_strength
